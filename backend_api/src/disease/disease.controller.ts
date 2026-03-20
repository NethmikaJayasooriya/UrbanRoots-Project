import { Controller, Get, Query, BadRequestException } from '@nestjs/common';
import { DiseaseService } from './disease.service';

@Controller('disease')
export class DiseaseController {
  constructor(private readonly diseaseService: DiseaseService) {}

  @Get('treatment')
  async getTreatmentPlan(@Query('name') diseaseName: string) {
    if (!diseaseName) {
      throw new BadRequestException('Disease name is required');
    }
    
    const treatmentOptions = await this.diseaseService.generateTreatmentPlan(diseaseName);
    return {
      success: true,
      disease: diseaseName,
      treatment: treatmentOptions,
    };
  }
}
