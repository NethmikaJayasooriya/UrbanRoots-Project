import { Controller, Get, Post, Body, Param, Headers, UnauthorizedException, Delete, Query } from '@nestjs/common';
import { MarketplaceService } from './marketplace.service';

@Controller('marketplace')
export class MarketplaceController {
  constructor(private readonly marketplaceService: MarketplaceService) {}

  private extractUid(uid?: string) {
    if (!uid) throw new UnauthorizedException('Missing x-user-id header');
    return uid;
  }

  @Get('products')
  async getProducts() {
    return await this.marketplaceService.getProducts();
  }

  @Post('products')
  async createProduct(@Body() body: any) {
    return await this.marketplaceService.createProduct(body);
  }

  @Post('orders')
  async createOrder(
    @Headers('x-user-id') uid: string,
    @Body() orderData: any
  ) {
    return await this.marketplaceService.createOrder(orderData, this.extractUid(uid));
  }

  @Get('orders/me')
  async getMyOrders(
    @Headers('x-user-id') uid: string,
    @Query('phones') phonesQuery?: string
  ) {
    const phones = phonesQuery ? phonesQuery.split(',') : [];
    return await this.marketplaceService.getOrdersByUser(this.extractUid(uid), phones);
  }

  @Delete('orders/:orderId/cancel')
  async cancelOrder(
    @Headers('x-user-id') uid: string,
    @Param('orderId') orderId: string
  ) {
    return await this.marketplaceService.cancelOrder(orderId, this.extractUid(uid));
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
