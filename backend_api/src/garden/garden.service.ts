import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WeatherService } from '../weather/weather.service'; // ADDED: Import WeatherService
import { Garden } from './garden.entity';

@Injectable()
export class GardenService {
  constructor(
    @InjectRepository(Garden)
    private readonly gardenRepository: Repository<Garden>,
    // ADDED: Inject the WeatherService into this class
    private readonly weatherService: WeatherService, 
  ) {}

  async createGarden(gardenData: Partial<Garden>): Promise<Garden> {
    try {
      // .create() prepares the object, .save() actually inserts it into Supabase
      const newGarden = this.gardenRepository.create(gardenData);
      return await this.gardenRepository.save(newGarden);
    } catch (error) {
      console.error("Error saving to Supabase:", error);
      throw new InternalServerErrorException('Failed to create garden');
    }
  }

  // ADDED: NEW METHOD FOR THE DASHBOARD AND DIGITAL PET
  async getGardenStatus(gardenId: number) {
    // 1. Find the specific garden in Supabase
    const garden = await this.gardenRepository.findOne({ where: { garden_id: gardenId } });
    if (!garden) throw new NotFoundException('Garden not found');

    // 2. Fetch live weather using the saved GPS coordinates
  let weatherData: any = null;
    if (garden.latitude && garden.longitude) {
       weatherData = await this.weatherService.getLiveWeather(garden.latitude, garden.longitude);
    }

    // 3. The Digital Pet Logic (Context-Aware AI)
    let petMessage = "Conditions look great for your plants!";
    if (weatherData && weatherData.humidity > 80 && garden.environment === 'Indoor') {
       petMessage = "It's pretty humid in here! Make sure there's good airflow.";
    } else if (weatherData && weatherData.temperature > 32 && garden.environment === 'Rooftop') {
       petMessage = "It's scorching outside! Your rooftop plants might need extra water today.";
    }

    // 4. Return the complete package to Flutter
    return {
      success: true,
      garden_name: garden.garden_name,
      live_weather: weatherData,
      digital_pet_advice: petMessage
    };
  }
}