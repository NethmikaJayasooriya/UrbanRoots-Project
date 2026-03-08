
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GardenController } from './garden.controller';
import { Garden } from './garden.entity';
import { GardenService } from './garden.service';

@Module({
  // This line is crucial! It gives the Service access to the database table.
  imports: [TypeOrmModule.forFeature([Garden])], 
  controllers: [GardenController],
  providers: [GardenService]
})
export class GardenModule {}