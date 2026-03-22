import { Body, Controller, Get, Post, Headers, UnauthorizedException } from '@nestjs/common';
import { SellerService } from './seller.service';

@Controller('seller')
export class SellerController {
  constructor(private readonly sellerService: SellerService) {}

  private extractUid(uid?: string) {
    if (!uid) throw new UnauthorizedException('Missing x-user-id header');
    return uid;
  }

  @Get()
  getSeller(@Headers('x-user-id') uid: string) {
    return this.sellerService.getSeller(this.extractUid(uid));
  }

  @Post('start')
  start(@Headers('x-user-id') uid: string) {
    return this.sellerService.startOnboarding(this.extractUid(uid));
  }

  @Post('identity')
  completeIdentity(@Headers('x-user-id') uid: string) {
    return this.sellerService.completeIdentity(this.extractUid(uid));
  }

  @Post('shop')
  updateShop(
    @Headers('x-user-id') uid: string,
    @Body() body: { shop_name: string; shop_description: string }
  ) {
    return this.sellerService.updateShopDetails(
      this.extractUid(uid),
      body.shop_name,
      body.shop_description,
    );
  }

  @Post('payout')
  setPayout(
    @Headers('x-user-id') uid: string,
    @Body() body: { method: string }
  ) {
    return this.sellerService.setPayout(this.extractUid(uid), body.method);
  }
}
