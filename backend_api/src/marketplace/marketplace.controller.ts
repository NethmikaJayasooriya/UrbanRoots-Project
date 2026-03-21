import { Controller, Get, Post, Body } from '@nestjs/common';
import { MarketplaceService } from './marketplace.service';

@Controller('marketplace')
export class MarketplaceController {
  constructor(private readonly marketplaceService: MarketplaceService) {}

  @Get('products')
  getProducts() {
    return this.marketplaceService.getProducts();
  }

  @Post('orders')
  createOrder(@Body() orderData: any) {
    return this.marketplaceService.createOrder(orderData);
  }

  @Post('payhere/notify')
  handlePayHereNotification(@Body() payload: any) {
    return this.marketplaceService.handlePayHereNotification(payload);
  }
}
