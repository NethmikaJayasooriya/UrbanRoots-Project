import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Seller } from './entities/seller.entity';
import { SellersService } from './sellers.service';
import { SellersController } from './sellers.controller';
import { UsersModule } from '../users/users.module';
import { MarketplaceModule } from '../marketplace/marketplace.module';

@Module({
  imports: [TypeOrmModule.forFeature([Seller]), UsersModule, MarketplaceModule],
  providers: [SellersService],
  controllers: [SellersController],
  exports: [SellersService],
})
export class SellersModule {}
