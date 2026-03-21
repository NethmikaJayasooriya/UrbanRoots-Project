import { Body, Controller, Get, Post } from '@nestjs/common';
import { SellerService } from './seller.service';

@Controller('seller')
export class SellerController {
  constructor(private readonly sellerService: SellerService) {}

  @Get()
  getSeller() {
    return this.sellerService.getSeller();
  }

  @Post('start')
  start() {
    return this.sellerService.startOnboarding();
  }

  @Post('identity')
  completeIdentity() {
    return this.sellerService.completeIdentity();
  }

  @Post('shop')
  updateShop(@Body() body: { shop_name: string; shop_description: string }) {
    return this.sellerService.updateShopDetails(
      body.shop_name,
      body.shop_description,
    );
  }

  @Post('payout')
  setPayout(@Body() body: { method: string }) {
    return this.sellerService.setPayout(body.method);
  }
}
