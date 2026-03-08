
import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Garden } from './garden.entity';

@Injectable()
export class GardenService {
  constructor(
    @InjectRepository(Garden)
    private readonly gardenRepository: Repository<Garden>,
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
}