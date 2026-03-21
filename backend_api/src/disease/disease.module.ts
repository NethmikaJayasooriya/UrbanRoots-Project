import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DiseaseController } from './disease.controller';
import { DiseaseService } from './disease.service';

@Module({
  imports: [ConfigModule],
  controllers: [DiseaseController],
  providers: [DiseaseService],
})
export class DiseaseModule {}
