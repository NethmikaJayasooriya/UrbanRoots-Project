import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { MarketplaceService } from './marketplace.service';

@Controller('marketplace')
export class MarketplaceController {
  constructor(private readonly marketplaceService: MarketplaceService) {}

  @Get('products')
  async getProducts() {
    return await this.marketplaceService.getProducts();
  }

  @Post('orders')
  async createOrder(@Body() orderData: any) {
    return await this.marketplaceService.createOrder(orderData);
  }

  @Get('orders/:phone')
  async getOrdersByPhone(@Param('phone') phone: string) {
    return await this.marketplaceService.getOrdersByPhone(phone);
  }

  @Post('payhere/notify')
  async handlePayHereNotification(@Body() payload: any) {
    return await this.marketplaceService.handlePayHereNotification(payload);
  }

  @Get('products/:productId/reviews')
  async getReviews(@Param('productId') productId: string) {
    return await this.marketplaceService.getReviews(productId);
  }

  @Post('products/:productId/reviews')
  async addReview(@Param('productId') productId: string, @Body() reviewData: any) {
    return await this.marketplaceService.addReview(productId, reviewData);
  }

  @Get('products/:productId/related')
  async getRelatedProducts(@Param('productId') productId: string) {
    return await this.marketplaceService.getRelatedProducts(productId);
  }
}

