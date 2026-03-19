import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WeatherModule } from '../weather/weather.module';
import { ActiveCrop } from './active-crop.entity';
import { GardenController } from './garden.controller';
import { Garden } from './garden.entity';
import { GardenService } from './garden.service';

@Module({
  imports: [TypeOrmModule.forFeature([Garden, ActiveCrop]), WeatherModule], 
  controllers: [GardenController],
  providers: [GardenService]
})
export class GardenModule {}