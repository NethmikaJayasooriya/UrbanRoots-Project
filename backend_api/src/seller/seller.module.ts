import { Module } from '@nestjs/common';
import { SellerController } from './seller.controller';
import { SellerService } from './seller.service';
import { SupabaseModule } from '../common/supabase/supabase.module';
import { MarketplaceModule } from '../marketplace/marketplace.module';

@Module({
  imports: [SupabaseModule, MarketplaceModule],
  controllers: [SellerController],
  providers: [SellerService],
  exports: [SellerService],
})
export class SellerModule {}
