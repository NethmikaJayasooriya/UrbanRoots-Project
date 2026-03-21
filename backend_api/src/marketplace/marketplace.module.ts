import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MarketplaceController } from './marketplace.controller';
import { MarketplaceService } from './marketplace.service';
import { Product } from './entities/product.entity';
<<<<<<< HEAD
=======
import { Seller } from './entities/seller.entity';
>>>>>>> 1823ea291d5656955397d4cf7d7e5d97a1b06878
import { Review } from './entities/review.entity';
import { Order } from './entities/order.entity';

@Module({
<<<<<<< HEAD
  imports: [TypeOrmModule.forFeature([Product, Review, Order])],
  controllers: [MarketplaceController],
  providers: [MarketplaceService],
=======
  imports: [TypeOrmModule.forFeature([Product, Seller, Review, Order])],
  controllers: [MarketplaceController],
  providers: [MarketplaceService],
  exports: [MarketplaceService],
>>>>>>> 1823ea291d5656955397d4cf7d7e5d97a1b06878
})
export class MarketplaceModule {}
