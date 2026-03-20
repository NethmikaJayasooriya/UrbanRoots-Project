import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { GardenService } from './garden.service';

@Controller('gardens')
export class GardenController {
  constructor(private readonly gardenService: GardenService) {}

  @Post()
  async createGardenEndpoint(@Body() body: any) {
    const savedGarden = await this.gardenService.createGarden(body);
    return { success: true, message: "Garden successfully created!", data: savedGarden };
  }

  @Get(':id/status')
  async getDashboardStatus(@Param('id') id: string) {
    return await this.gardenService.getGardenStatus(Number(id));
  }

  @Get(':id/recommendations')
  async getAiRecommendations(@Param('id') id: string) {
    return await this.gardenService.generateCropRecommendations(Number(id));
  }

  @Post(':id/crops')
  async addCropToGarden(@Param('id') id: string, @Body('plant_name') plantName: string) {
    if (!plantName) return { success: false, message: "plant_name is required" };
    const savedCrop = await this.gardenService.addCropToGarden(Number(id), plantName);
    return { success: true, message: `${plantName} successfully added to your garden!`, data: savedCrop };
  }

  @Get(':id/crops')
  async getGardenCrops(@Param('id') id: string) {
    const crops = await this.gardenService.getGardenCrops(Number(id));
    return { success: true, data: crops };
  }

  @Patch(':id/link-pet')
  async linkPetToPlant(@Param('id') gardenId: string, @Body('crop_id') cropId: number) {
    await this.gardenService.linkPlantToPet(Number(gardenId), cropId);
    return { success: true, message: "Pet successfully linked to new plant." };
  }

  // NEW ENDPOINT: Saves the updated task list
  @Patch(':id/crops/:cropId/tasks')
  async updateCropTasks(
    @Param('cropId') cropId: string,
    @Body('tasks') tasks: any[]
  ) {
    await this.gardenService.updateCropTasks(Number(cropId), tasks);
    return { success: true, message: "Tasks successfully updated." };
  }

  // IoT real-time alert — called by Flutter when a sensor crosses a threshold.
  // Returns AI-generated plant-specific pet_dialogue + care_action.
  @Post(':id/iot-alert')
  async handleIoTAlert(@Param('id') id: string, @Body() body: any) {
    const result = await this.gardenService.processIoTAlert(Number(id), body);
    return { success: true, ...result };
  }
}