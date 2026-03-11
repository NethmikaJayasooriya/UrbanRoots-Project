import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WeatherModule } from '../weather/weather.module'; // ADDED: Import the new WeatherModule
import { GardenController } from './garden.controller';
import { Garden } from './garden.entity';
import { GardenService } from './garden.service';

@Module({
  // ADDED: WeatherModule is now in the imports array
  imports: [TypeOrmModule.forFeature([Garden]), WeatherModule], 
  controllers: [GardenController],
  providers: [GardenService]
})
export class GardenModule {}