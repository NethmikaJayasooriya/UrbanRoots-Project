import { GoogleGenerativeAI } from '@google/generative-ai';
import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WeatherService } from '../weather/weather.service';
import { ActiveCrop } from './active-crop.entity';
import { Garden } from './garden.entity';

@Injectable()
export class GardenService {
  constructor(
    @InjectRepository(Garden)
    private readonly gardenRepository: Repository<Garden>,
    @InjectRepository(ActiveCrop)
    private readonly activeCropRepository: Repository<ActiveCrop>,
    private readonly weatherService: WeatherService,
    private readonly configService: ConfigService, // Added ConfigService here
  ) {}

  async createGarden(gardenData: Partial<Garden>): Promise<Garden> {
    try {
      const newGarden = this.gardenRepository.create(gardenData);
      return await this.gardenRepository.save(newGarden);
    } catch (error) {
      console.error("Error saving to database:", error);
      throw new InternalServerErrorException('Failed to create garden');
    }
  }

  async getGardenStatus(gardenId: number) {
    const garden = await this.gardenRepository.findOne({ where: { garden_id: gardenId } });
    if (!garden) throw new NotFoundException('Garden not found');

    let weatherData: any = null;
    if (garden.latitude && garden.longitude) {
       weatherData = await this.weatherService.getLiveWeather(garden.latitude, garden.longitude);
    }

    // Get all crops to generate customized tips
    const allCrops = await this.activeCropRepository.find({ where: { garden_id: gardenId } });
    const cropNames = allCrops.map(c => c.plant_name).join(', ');

    const linkedPlant = allCrops.find(c => c.is_linked_to_pet === true);

    let petMood = 'happy'; 
    const isThirstyIoT = weatherData && weatherData.humidity < 40;
    
    let hasPendingTasks = false;
    let allTasksDone = false;
    let pendingTaskTitle = "None";

    if (linkedPlant && linkedPlant.daily_tasks && linkedPlant.daily_tasks.length > 0) {
      const pendingTask = linkedPlant.daily_tasks.find((t: any) => t.isDone === false);
      if (pendingTask) {
        hasPendingTasks = true;
        pendingTaskTitle = pendingTask.title;
      } else {
        allTasksDone = true;
      }
    }

    if (isThirstyIoT) { petMood = 'sad'; } 
    else if (hasPendingTasks) { petMood = 'neutral'; } 
    else if (allTasksDone) { petMood = 'super_happy'; }

    let petMessage = "We're thriving! ✨";
    let dynamicInsight = "Environmental conditions are stable.";

    try {
      // Safely pulling the API key from the .env file
     const apiKey = this.configService.get<string>('GEMINI_API_KEY')!; 
const genAI = new GoogleGenerativeAI(apiKey);
      const model = genAI.getGenerativeModel({ 
        model: 'gemini-2.5-flash',
        generationConfig: { responseMimeType: "application/json" }
      });
      
      // Combined prompt for performance: gets both Pet Dialogue and a Quick Tip at the same time
      const prompt = `
        Act as an expert botanist and a digital plant pet.
        Context:
        - Linked Plant: ${linkedPlant ? linkedPlant.plant_name : 'No plant'}
        - All Plants in Garden: ${cropNames || 'None yet'}
        - Weather: ${weatherData?.temperature || 'Unknown'}°C, ${weatherData?.humidity || 'Unknown'}% humidity.
        - Pending Task: ${pendingTaskTitle}
        - Current State: ${isThirstyIoT ? 'Very Thirsty' : hasPendingTasks ? 'Needs attention for task' : allTasksDone ? 'All tasks complete' : 'Happy'}

        Generate a JSON response with two keys:
        1. "pet_dialogue": EXACTLY ONE short, sweet, conversational sentence (max 10 words) from the pet's perspective with an emoji.
        2. "quick_tip": If there is a Pending Task, make this a polite reminder. If All tasks are complete (or no tasks exist), generate ONE fascinating, highly specific botanical quick tip or fun fact about growing the "All Plants in Garden".

        Format: {"pet_dialogue": "...", "quick_tip": "..."}
      `;

      const result = await model.generateContent(prompt);
      const data = JSON.parse(result.response.text());
      petMessage = data.pet_dialogue || petMessage;
      dynamicInsight = data.quick_tip || dynamicInsight;
      
    } catch (error) {
      if (isThirstyIoT) petMessage = "It's dry... I'm thirsty! 💧";
      else if (hasPendingTasks) {
        petMessage = "Don't forget my tasks! 📋";
        dynamicInsight = `Reminder: ${pendingTaskTitle}`;
      } else if (allTasksDone) petMessage = "Yay! All tasks are done! 🎉";
    }

    return {
      success: true,
      garden_name: garden.garden_name,
      live_weather: weatherData,
      linked_plant_name: linkedPlant?.plant_name || "Garden",
      priority_notification: dynamicInsight,
      pet_status: { mood: petMood, message: petMessage, is_thirsty: isThirstyIoT }
    };
  }

  async linkPlantToPet(gardenId: number, cropId: number) {
    await this.activeCropRepository.update({ garden_id: gardenId }, { is_linked_to_pet: false });
    return await this.activeCropRepository.update(cropId, { is_linked_to_pet: true });
  }

  async updateCropTasks(cropId: number, tasks: any[]) {
    const crop = await this.activeCropRepository.findOne({ where: { id: cropId } });
    if (!crop) throw new NotFoundException('Crop not found');
    crop.daily_tasks = tasks;
    return await this.activeCropRepository.save(crop);
  }

  async generateCropRecommendations(gardenId: number) {
    const garden = await this.gardenRepository.findOne({ where: { garden_id: gardenId } });
    if (!garden) throw new NotFoundException('Garden not found');

    let weatherData: any = null;
    if (garden.latitude && garden.longitude) {
       weatherData = await this.weatherService.getLiveWeather(garden.latitude, garden.longitude);
    }

    const supportedCrops = [
      "crape jasmine", "Bauhinia acuminata", "Hibiscus", "night flowering jasmine", "rose",
      "bell pepper", "tomato", "soyabean", "potato",
      "blueberry", "cherry", "grape", "strawberry", "raspberry", "orange"
    ];

    try {
      // Safely pulling the API key from the .env file
   const apiKey = this.configService.get<string>('GEMINI_API_KEY')!; 
const genAI = new GoogleGenerativeAI(apiKey);
      const model = genAI.getGenerativeModel({ 
        model: 'gemini-2.5-flash',
        generationConfig: { responseMimeType: "application/json" } 
      });

      // Extract target categories specifically chosen by user if they exist
      const targetCategories = Array.isArray(garden.target_crops) && garden.target_crops.length > 0 
        ? garden.target_crops.join(', ') 
        : 'Any suitable type';

      // UPDATED PROMPT: Feeds the entirety of the user's garden profile into Gemini
      const prompt = `
        You are an expert botanist. Analyze this garden setup in Sri Lanka to recommend the best crops:
        
        Environmental Factors:
        - Location Type: ${garden.environment}
        - Soil Type: ${garden.soil_type}
        - Wind Exposure: ${garden.is_windy ? 'High (Windy)' : 'Low/Normal'}
        - Live Temperature: ${weatherData?.temperature || 'Unknown'}°C
        - Live Humidity: ${weatherData?.humidity || 'Unknown'}%
        - Typical Sunlight: ${garden.sunlight_level}% (0=Shadow, 100=Direct)

        User Constraints & Goals:
        - Experience Level: ${garden.experience_level || 'Beginner'}
        - Primary Goal: ${garden.gardening_goal || 'Max Yield'}
        - Container Size: ${garden.container_size || 'Medium'}
        - Watering Frequency: ${garden.watering_frequency || 'Daily'}
        - Preferred Crop Categories: ${targetCategories}
        
        Select the best 4 to 7 crops from this EXACT list ONLY: ${supportedCrops.join(', ')}.
        Do NOT include any crop not on this list. Prioritize selections that align with the user's experience level, watering frequency, and preferred categories.

        Return ONLY a raw JSON array. Each object must have strictly these keys:
        - "plant_name": The exact name from the list.
        - "success_probability": A realistic percentage string (e.g., "85%") based on the match between plant needs and user constraints.
        - "short_reason": One short sentence explaining why it fits these specific conditions and user preferences.
      `;

      const result = await model.generateContent(prompt);
      const aiResponseText = result.response.text();

      const objectMatches = aiResponseText.match(/\{[^{}]*"plant_name"[^{}]*\}/g);

      if (!objectMatches || objectMatches.length === 0) {
        throw new Error("AI failed to return a valid JSON array format");
      }

      const recommendationsArray = objectMatches.reduce<object[]>((acc, raw) => {
        try { acc.push(JSON.parse(raw)); } catch {}
        return acc;
      }, []);

      if (recommendationsArray.length === 0) {
        throw new Error("AI failed to return any valid crop recommendation objects");
      }

      return {
        success: true,
        garden_name: garden.garden_name,
        recommendations: recommendationsArray
      };

    } catch (error) {
      console.error("Error generating recommendations:", error);
      throw new InternalServerErrorException('Failed to generate crop recommendations');
    }
  }

  async addCropToGarden(gardenId: number, plantName: string) {
    const garden = await this.gardenRepository.findOne({ where: { garden_id: gardenId } });
    if (!garden) throw new NotFoundException('Garden not found');

    let weatherData: any = null;
    if (garden.latitude && garden.longitude) {
       weatherData = await this.weatherService.getLiveWeather(garden.latitude, garden.longitude);
    }

    // Safely pulling the API key from the .env file
    const apiKey = this.configService.get<string>('GEMINI_API_KEY')!; 
const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ 
      model: 'gemini-2.5-flash',
      generationConfig: { responseMimeType: "application/json" } 
    });

    // HIGHLY SPECIFIC TASK PROMPT
    const prompt = `
      You are a Master Botanist. The user just added a ${plantName} to their ${garden.environment} garden (${garden.soil_type}).
      Current weather: ${weatherData?.temperature || 'Unknown'}°C, ${weatherData?.humidity || 'Unknown'}% humidity.

      Generate exactly 3 HIGHLY UNIQUE, plant-specific daily tasks for today.
      Do NOT give generic tasks like "Water the plant." Give specific instructions tailored to ${plantName}'s biology and the current weather.
      Example for Tomato: "Prune the bottom suckers to improve airflow", "Check under leaves for hornworms".

      Return exactly 3 tasks as a raw JSON array.
      Format: [{"time": "HH:MM AM", "title": "Specific task description", "isDone": false}]
    `;

    try {
      const result = await model.generateContent(prompt);
      const tasksMatches = result.response.text().match(/\{[^{}]*"title"[^{}]*\}/g);
      let dailyTasks: object[] = [];
      
      if (tasksMatches) {
        dailyTasks = tasksMatches.reduce<object[]>((acc, raw) => {
          try { acc.push(JSON.parse(raw)); } catch {}
          return acc;
        }, []);
      }

      const newCrop = this.activeCropRepository.create({
        garden_id: gardenId,
        plant_name: plantName,
        status: 'Healthy',
        daily_tasks: dailyTasks
      });

      return await this.activeCropRepository.save(newCrop);

    } catch (error) {
      console.error("Error generating tasks or saving crop:", error);
      throw new InternalServerErrorException('Failed to add crop to garden');
    }
  }

  async getGardenCrops(gardenId: number) {
    try {
      return await this.activeCropRepository.find({
        where: { garden_id: gardenId },
        order: { id: 'DESC' }
      });
    } catch (error) {
      console.error("Error fetching garden crops:", error);
      throw new InternalServerErrorException('Failed to fetch crops');
    }
  }
}