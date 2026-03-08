// src/garden/garden.controller.ts
import { Body, Controller, Post } from '@nestjs/common';
import { GardenService } from './garden.service';

@Controller('gardens') // This means the URL will be http://localhost:3000/gardens
export class GardenController {
  constructor(private readonly gardenService: GardenService) {}

  @Post()
  async createGardenEndpoint(@Body() body: any) {
    console.log("Received data from Flutter:", body);
    
    // Pass the incoming JSON straight to the service
    const savedGarden = await this.gardenService.createGarden(body);
    
    return {
      success: true,
      message: "Garden successfully created!",
      data: savedGarden
    };
  }
}