import { GenerativeModel, GoogleGenerativeAI } from '@google/generative-ai';
import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WeatherService } from '../weather/weather.service';
import { ActiveCrop } from './active-crop.entity';
import { Garden } from './garden.entity';

// ─── Canonical source of truth for all supported plants ──────────────────────
// Keys are lowercase (for case-insensitive matching against user input).
// Values are the canonical display names used in prompts and returned to client.
const SUPPORTED_CROPS: Record<string, string> = {
  "crape jasmine":          "crape jasmine",
  "bauhinia acuminata":     "Bauhinia acuminata",
  "hibiscus":               "Hibiscus",
  "night flowering jasmine":"night flowering jasmine",
  "rose":                   "rose",
  "bell pepper":            "bell pepper",
  "tomato":                 "tomato",
  "soyabean":               "soyabean",
  "potato":                 "potato",
  "blueberry":              "blueberry",
  "cherry":                 "cherry",
  "grape":                  "grape",
  "strawberry":             "strawberry",
  "raspberry":              "raspberry",
  "orange":                 "orange",
};

// Helper: resolve a raw string to its canonical name, or null if unsupported.
function toCanonical(name: string): string | null {
  return SUPPORTED_CROPS[name.trim().toLowerCase()] ?? null;
}

@Injectable()
export class GardenService {
  // Single Gemini model instance shared across all methods.
  private geminiModel: GenerativeModel;

  constructor(
    @InjectRepository(Garden)
    private readonly gardenRepository: Repository<Garden>,
    @InjectRepository(ActiveCrop)
    private readonly activeCropRepository: Repository<ActiveCrop>,
    private readonly weatherService: WeatherService,
    private readonly configService: ConfigService,
  ) {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY')!;
    const genAI = new GoogleGenerativeAI(apiKey);
    this.geminiModel = genAI.getGenerativeModel({
      model: 'gemini-2.5-flash',
      generationConfig: { responseMimeType: 'application/json' },
    });
  }

  // ─── Utility: safe JSON parse with fallback value ───────────────────────────
  private safeParseJson<T>(text: string, fallback: T): T {
    try {
      return JSON.parse(text) as T;
    } catch {
      return fallback;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // createGarden
  // ──────────────────────────────────────────────────────────────────────────────
  async createGarden(gardenData: Partial<Garden>): Promise<Garden> {
    try {
      const newGarden = this.gardenRepository.create(gardenData);
      return await this.gardenRepository.save(newGarden);
    } catch (error) {
      console.error('Error saving to database:', error);
      throw new InternalServerErrorException('Failed to create garden');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // getGardenStatus  (dashboard / digital pet)
  // ──────────────────────────────────────────────────────────────────────────────
  async getGardenStatus(gardenId: number) {
    const garden = await this.gardenRepository.findOne({ where: { garden_id: gardenId } });
    if (!garden) throw new NotFoundException('Garden not found');

    let weatherData: any = null;
    if (garden.latitude && garden.longitude) {
      weatherData = await this.weatherService.getLiveWeather(garden.latitude, garden.longitude);
    }

    const allCrops = await this.activeCropRepository.find({ where: { garden_id: gardenId } });
    const cropNames = allCrops.map(c => c.plant_name).join(', ');
    const linkedPlant = allCrops.find(c => c.is_linked_to_pet === true);

    // ── Mood logic ──────────────────────────────────────────────────────────────
    const isThirsty = weatherData && weatherData.humidity < 40;
    let hasPendingTasks = false;
    let allTasksDone = false;
    let pendingTaskTitle = 'None';

    if (linkedPlant && linkedPlant.daily_tasks && linkedPlant.daily_tasks.length > 0) {
      const pending = linkedPlant.daily_tasks.find((t: any) => t.isDone === false);
      if (pending) {
        hasPendingTasks = true;
        pendingTaskTitle = pending.title;
      } else {
        allTasksDone = true;
      }
    }

    let petMood = 'happy';
    if (isThirsty) petMood = 'sad';
    else if (hasPendingTasks) petMood = 'neutral';
    else if (allTasksDone) petMood = 'super_happy';

    // ── Defaults in case AI fails ───────────────────────────────────────────────
    let petMessage = "We're thriving! ✨";
    let dynamicInsight = 'Environmental conditions are stable.';

    try {
      const currentState = isThirsty
        ? 'Very Thirsty — humidity is critically low'
        : hasPendingTasks
        ? `Needs attention: "${pendingTaskTitle}" is overdue`
        : allTasksDone
        ? 'All tasks complete for today'
        : 'Happy and healthy';

      const prompt = `
        You are an expert botanist playing the role of a digital plant companion.

        Garden Context:
        - Linked Plant (the pet): ${linkedPlant ? linkedPlant.plant_name : 'No plant linked yet'}
        - All Plants in Garden: ${cropNames || 'None yet'}
        - Live Weather: ${weatherData?.temperature ?? 'Unknown'}°C, ${weatherData?.humidity ?? 'Unknown'}% humidity
        - Current State: ${currentState}

        Generate EXACTLY this JSON object (no other text):
        {
          "pet_dialogue": "<One short, warm sentence ≤10 words from the plant pet's perspective, include one emoji>",
          "quick_tip": "<${
            hasPendingTasks
              ? `A polite one-sentence reminder to complete the pending task: "${pendingTaskTitle}"`
              : `ONE highly specific, fascinating botanical fact or actionable tip about growing ${cropNames || 'plants'} in tropical Sri Lanka conditions (${weatherData?.temperature ?? '~29'}°C, ${weatherData?.humidity ?? '~75'}% humidity)`
          }>"
        }
      `.trim();

      const result = await this.geminiModel.generateContent(prompt);
      const data = this.safeParseJson<any>(result.response.text(), {});
      if (data.pet_dialogue) petMessage = data.pet_dialogue;
      if (data.quick_tip) dynamicInsight = data.quick_tip;

    } catch (error) {
      console.error('Gemini status prompt failed:', error);
      // Meaningful fallbacks — never show raw errors to the user
      if (isThirsty) {
        petMessage = "It's dry... I'm thirsty! 💧";
        dynamicInsight = 'Humidity is low — consider misting leaves or moving to a shadier spot.';
      } else if (hasPendingTasks) {
        petMessage = "Don't forget my tasks! 📋";
        dynamicInsight = `Reminder: ${pendingTaskTitle}`;
      } else if (allTasksDone) {
        petMessage = 'Yay! All tasks are done! 🎉';
        dynamicInsight = 'Great job keeping up with your garden today!';
      }
    }

    return {
      success: true,
      garden_name: garden.garden_name,
      live_weather: weatherData,
      linked_plant_name: linkedPlant?.plant_name ?? 'Garden',
      priority_notification: dynamicInsight,
      pet_status: { mood: petMood, message: petMessage, is_thirsty: isThirsty },
    };
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // generateCropRecommendations  — the core fix
  // ──────────────────────────────────────────────────────────────────────────────
  async generateCropRecommendations(gardenId: number) {
    const garden = await this.gardenRepository.findOne({ where: { garden_id: gardenId } });
    if (!garden) throw new NotFoundException('Garden not found');

    let weatherData: any = null;
    if (garden.latitude && garden.longitude) {
      weatherData = await this.weatherService.getLiveWeather(garden.latitude, garden.longitude);
    }

    // ── Step 1: Resolve user selections to canonical names ──────────────────────
    // The Flutter fix now sends exact plant names (e.g. "tomato", "hibiscus").
    // We normalise casing so "Hibiscus" and "hibiscus" both resolve correctly.
    const userSelections: string[] = Array.isArray(garden.target_crops) ? garden.target_crops : [];

    const confirmedPreferences: string[] = userSelections
      .map(toCanonical)
      .filter((name): name is string => name !== null);

    // The plants the AI is allowed to pick from for supplementary slots
    const allCanonicalCrops = Object.values(SUPPORTED_CROPS);

    // Plants NOT already locked in by user preferences (AI fills remaining slots from these)
    const supplementaryPool = allCanonicalCrops.filter(
      crop => !confirmedPreferences.includes(crop),
    );

    // ── Step 2: Build a context-aware, enforcement-first prompt ────────────────
    const mandatorySection = confirmedPreferences.length > 0
      ? `
MANDATORY INCLUSIONS (user explicitly requested these — they ARE in the supported list):
${confirmedPreferences.map((p, i) => `  ${i + 1}. ${p}`).join('\n')}
You MUST include ALL of the above in your response. Do not drop any of them regardless of environment.
Then SUPPLEMENT with additional plants from the pool below to reach a total of 4–7 recommendations.
Supplementary pool to draw from: ${supplementaryPool.join(', ')}.
`.trim()
      : `
No specific plants were requested. Select the best 4–7 plants purely on environmental and constraint fit from this list: ${allCanonicalCrops.join(', ')}.
`.trim();

    const prompt = `
You are a senior botanist specialising in tropical home gardening in Sri Lanka.
Your job is to recommend the best crops for this specific garden and EXPLAIN why with precise botanical reasoning.

── GARDEN PROFILE ────────────────────────────────────────────────────────────
Environment:
  - Space Type:        ${garden.environment}
  - Soil Type:         ${garden.soil_type ?? 'Unknown'}
  - Wind Exposure:     ${garden.is_windy ? 'High (above 3rd-floor balcony)' : 'Low / sheltered'}
  - Container Size:    ${garden.container_size ?? 'Medium'}
  - Typical Sunlight:  ${garden.sunlight_level ?? 50}% (0 = deep shade, 100 = full direct sun)
  - Watering Habit:    ${garden.watering_frequency ?? 'Daily'}

Live Weather (real-time, Sri Lanka):
  - Temperature:       ${weatherData?.temperature ?? 'Unknown'}°C
  - Humidity:          ${weatherData?.humidity ?? 'Unknown'}%

User Goals & Constraints:
  - Experience Level:  ${garden.experience_level ?? 'Beginner'}
  - Primary Goal:      ${garden.gardening_goal ?? 'Max Yield'}

── YOUR TASK ─────────────────────────────────────────────────────────────────
${mandatorySection}

For EACH recommended plant, assign a realistic success_probability (0–100%) by reasoning through:
  a) Soil compatibility with this plant's root system
  b) Sunlight match (${garden.sunlight_level ?? 50}% vs plant's ideal range)
  c) Temperature tolerance vs current ${weatherData?.temperature ?? '~30'}°C
  d) Wind tolerance if is_windy = ${garden.is_windy}
  e) Container size suitability (${garden.container_size ?? 'Medium'})
  f) Watering match (${garden.watering_frequency ?? 'Daily'} vs plant's water needs)
  g) Experience alignment (${garden.experience_level ?? 'Beginner'} gardener)
User-preferred plants may score slightly lower if environment is suboptimal — be honest, not flattering.

── OUTPUT FORMAT ─────────────────────────────────────────────────────────────
Return ONLY a valid JSON array. No preamble, no markdown, no extra keys.
[
  {
    "plant_name": "<exact name from the supported list>",
    "success_probability": "<realistic %, e.g. 78%>",
    "short_reason": "<one sentence: why it fits THIS garden's specific environment AND the user's goal/experience>",
    "is_user_preference": <true if this was in the mandatory list, false otherwise>
  }
]
    `.trim();

    try {
      const result = await this.geminiModel.generateContent(prompt);
      const rawText = result.response.text();

      // ── Step 3: Parse — prefer full JSON.parse, fall back to regex ──────────
      let rawArray: any[] = [];

      // Try direct parse first (works when responseMimeType:"application/json" is honoured)
      const directParse = this.safeParseJson<any>(rawText, null);
      if (Array.isArray(directParse)) {
        rawArray = directParse;
      } else {
        // Fallback: extract individual objects via regex
        const matches: string[] = rawText.match(/\{[^{}]*"plant_name"[^{}]*\}/g) ?? [];
        rawArray = matches.reduce((acc: any[], raw: string) => {
          const parsed = this.safeParseJson<any>(raw, null);
          if (parsed) acc.push(parsed);
          return acc;
        }, [] as any[]);
      }

      // ── Step 4: Validate output — only allow supported canonical plant names ─
      const validated = rawArray
        .filter((item: any) => {
          const canonical = toCanonical(item?.plant_name ?? '');
          return canonical !== null;
        })
        .map((item: any) => ({
          plant_name: toCanonical(item.plant_name)!, // normalise to canonical casing
          success_probability: item.success_probability ?? 'N/A',
          short_reason: item.short_reason ?? '',
          is_user_preference: confirmedPreferences.includes(toCanonical(item.plant_name)!),
        }));

      // ── Step 5: Guarantee mandatory preferences are present even if AI forgot ─
      // (safety net — well-prompted Gemini should not need this, but never trust blindly)
      for (const pref of confirmedPreferences) {
        if (!validated.some(v => v.plant_name === pref)) {
          validated.unshift({
            plant_name: pref,
            success_probability: 'See note',
            short_reason: 'You requested this plant — add it and monitor its performance.',
            is_user_preference: true,
          });
        }
      }

      if (validated.length === 0) {
        throw new Error('AI returned no valid plant recommendations after validation.');
      }

      // Sort: user preferences first, then by probability (desc) for a clean UX order
      validated.sort((a, b) => {
        if (a.is_user_preference && !b.is_user_preference) return -1;
        if (!a.is_user_preference && b.is_user_preference) return 1;
        const pa = parseInt(a.success_probability) || 0;
        const pb = parseInt(b.success_probability) || 0;
        return pb - pa;
      });

      return {
        success: true,
        garden_name: garden.garden_name,
        recommendations: validated,
      };

    } catch (error) {
      console.error('Error generating recommendations:', error);
      throw new InternalServerErrorException('Failed to generate crop recommendations');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // addCropToGarden  — also upgraded: tasks now use full garden context
  // ──────────────────────────────────────────────────────────────────────────────
  async addCropToGarden(gardenId: number, plantName: string) {
    const garden = await this.gardenRepository.findOne({ where: { garden_id: gardenId } });
    if (!garden) throw new NotFoundException('Garden not found');

    let weatherData: any = null;
    if (garden.latitude && garden.longitude) {
      weatherData = await this.weatherService.getLiveWeather(garden.latitude, garden.longitude);
    }

    const prompt = `
You are a Master Botanist. Generate 3 highly specific daily care tasks for a ${plantName} just added to this garden.

Garden context:
  - Space Type:    ${garden.environment}
  - Soil:          ${garden.soil_type ?? 'Potting Mix'}
  - Container:     ${garden.container_size ?? 'Medium'}
  - Sunlight:      ${garden.sunlight_level ?? 50}% (0=shade, 100=direct)
  - Watering:      ${garden.watering_frequency ?? 'Daily'}
  - Wind:          ${garden.is_windy ? 'High exposure' : 'Sheltered'}
  - Gardener:      ${garden.experience_level ?? 'Beginner'}
  - Goal:          ${garden.gardening_goal ?? 'Max Yield'}
  - Weather:       ${weatherData?.temperature ?? 'Unknown'}°C, ${weatherData?.humidity ?? 'Unknown'}% humidity

Rules:
  - Tasks must be SPECIFIC to ${plantName}'s biology — no generic "water the plant" instructions.
  - Tasks must reference the actual environment (e.g. if windy, mention wind protection).
  - Time slots must be realistic for a home gardener (morning / midday / evening).
  - Calibrate complexity to a ${garden.experience_level ?? 'Beginner'} gardener.

Return ONLY a valid JSON array of exactly 3 objects, no other text:
[
  {"time": "HH:MM AM/PM", "title": "<specific task>", "isDone": false},
  {"time": "HH:MM AM/PM", "title": "<specific task>", "isDone": false},
  {"time": "HH:MM AM/PM", "title": "<specific task>", "isDone": false}
]
    `.trim();

    try {
      const result = await this.geminiModel.generateContent(prompt);
      const rawText = result.response.text();

      // Try full parse first, then regex fallback
      let dailyTasks: object[] = [];
      const directParse = this.safeParseJson<any>(rawText, null);
      if (Array.isArray(directParse)) {
        dailyTasks = directParse.slice(0, 3);
      } else {
        const matches: string[] = rawText.match(/\{[^{}]*"title"[^{}]*\}/g) ?? [];
        dailyTasks = matches.slice(0, 3).reduce((acc: any[], raw: string) => {
          const parsed = this.safeParseJson<any>(raw, null);
          if (parsed) acc.push(parsed);
          return acc;
        }, [] as any[]);
      }

      const newCrop = this.activeCropRepository.create({
        garden_id: gardenId,
        plant_name: plantName,
        status: 'Healthy',
        daily_tasks: dailyTasks,
      });

      return await this.activeCropRepository.save(newCrop);

    } catch (error) {
      console.error('Error generating tasks or saving crop:', error);
      throw new InternalServerErrorException('Failed to add crop to garden');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // linkPlantToPet
  // ──────────────────────────────────────────────────────────────────────────────
  async linkPlantToPet(gardenId: number, cropId: number) {
    await this.activeCropRepository.update({ garden_id: gardenId }, { is_linked_to_pet: false });
    return await this.activeCropRepository.update(cropId, { is_linked_to_pet: true });
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // updateCropTasks
  // ──────────────────────────────────────────────────────────────────────────────
  async updateCropTasks(cropId: number, tasks: any[]) {
    const crop = await this.activeCropRepository.findOne({ where: { id: cropId } });
    if (!crop) throw new NotFoundException('Crop not found');
    crop.daily_tasks = tasks;
    return await this.activeCropRepository.save(crop);
  }

  // ──────────────────────────────────────────────────────────────────────────────
  // getGardenCrops
  // ──────────────────────────────────────────────────────────────────────────────
  async getGardenCrops(gardenId: number) {
    try {
      return await this.activeCropRepository.find({
        where: { garden_id: gardenId },
        order: { id: 'DESC' },
      });
    } catch (error) {
      console.error('Error fetching garden crops:', error);
      throw new InternalServerErrorException('Failed to fetch crops');
    }
  }
}