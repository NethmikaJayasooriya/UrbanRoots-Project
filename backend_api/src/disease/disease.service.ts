import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Groq from 'groq-sdk';

@Injectable()
export class DiseaseService {
  constructor(private readonly configService: ConfigService) {}

  /**
   * Directly uses Groq (Llama 3.1) to construct a clean, practical 3-step plan.
   * Includes robust API key failover for rate limit protections.
   */
  async generateTreatmentPlan(diseaseName: string): Promise<string> {
    const keys = [
      this.configService.get<string>('GROQ_API_KEY'),
      this.configService.get<string>('GROQ_API_KEY_SECONDARY')
    ].filter(Boolean) as string[];

    if (keys.length === 0) {
      throw new InternalServerErrorException('No GROQ API keys configured');
    }

    const prompt = `
      You are an expert botanist and plant pathologist.
      The user's plant has just been diagnosed with the following disease: "${diseaseName}".
      
      Provide 4 to 5 practical steps to cure this disease.
      CRITICAL RULES:
      - ONLY output exactly 4 or 5 bullet points. No introductory text. No concluding text.
      - Each step MUST be a single, short sentence (Maximum 20 words).
      - Do NOT use any Markdown formatting (no asterisks, no bold text).
      - Keep it highly readable for a mobile app screen.
    `;

    // Failover Retry Loop
    for (const key of keys) {
      try {
        const groq = new Groq({ apiKey: key });
        const chatCompletion = await groq.chat.completions.create({
          messages: [{ role: 'user', content: prompt }],
          model: 'llama-3.1-8b-instant', 
        });

        // If successful, instantly return the parsed text and break the loop
        return chatCompletion.choices[0]?.message?.content || this._getFallbackText();
        
      } catch (error: any) {
        console.warn(`Groq key failed (possibly rate limit 429 or 401). Retrying with backup key...`);
      }
    }

    // Catastrophic failure - Every single key was exhausted/rate-limited
    console.error('All configured Groq API keys failed or hit rate limits!');
    return this._getFallbackText();
  }

  private _getFallbackText(): string {
    return `
1. **Isolate the Plant**: Immediately separate this plant from healthy ones to prevent the disease from spreading.
2. **Remove Infected Areas**: Carefully pinch or prune off the heavily affected leaves and dispose of them safely (not in compost).
3. **Monitor Closely**: Ensure the plant has proper air circulation and avoid overwatering while it recovers.

4. [SYS_ERR_LLM_OFFLINE]
    `.trim();
  }
}
