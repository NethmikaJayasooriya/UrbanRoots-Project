import { Controller, Get, Param, Post, Body } from '@nestjs/common';
import { MarketplaceService } from './marketplace.service';

@Controller('marketplace')
export class MarketplaceController {
  constructor(private readonly marketplaceService: MarketplaceService) {}

  @Get('products')
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
