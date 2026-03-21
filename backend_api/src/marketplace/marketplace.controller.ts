<<<<<<< HEAD
import { Controller, Get, Post, Body, Param } from '@nestjs/common';
=======
import { Controller, Get, Param, Post, Body } from '@nestjs/common';
>>>>>>> 1823ea291d5656955397d4cf7d7e5d97a1b06878
import { MarketplaceService } from './marketplace.service';

@Controller('marketplace')
export class MarketplaceController {
  constructor(private readonly marketplaceService: MarketplaceService) {}

  @Get('products')
<<<<<<< HEAD
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

=======
  getProducts() {
    return this.marketplaceService.getProducts();
  }

  @Post('products')
  createProduct(@Body() body: any) {
    return this.marketplaceService.createProduct(body);
  }

  @Get('products/:productId/reviews')
  getReviews(@Param('productId') productId: string) {
    return this.marketplaceService.getProductReviews(productId);
  }

  @Post('reviews')
  addReview(@Body() body: any) {
    return this.marketplaceService.addReview(body);
  }

  @Post('orders')
  submitOrder(@Body() body: any) {
    return this.marketplaceService.submitOrder(body);
  }
}
>>>>>>> 1823ea291d5656955397d4cf7d7e5d97a1b06878
