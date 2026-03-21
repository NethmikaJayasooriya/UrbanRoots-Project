import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from './entities/product.entity';
import { Review } from './entities/review.entity';
import { Order } from './entities/order.entity';

@Injectable()
export class MarketplaceService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    @InjectRepository(Review)
    private readonly reviewRepository: Repository<Review>,
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
  ) {}

  // Get all products
  async getProducts(): Promise<Product[]> {
    try {
      return await this.productRepository.find();
    } catch (error: any) {
      throw new InternalServerErrorException('Failed to fetch products', error.message);
    }
  }

  // Create a new product (Seller Upload)
  async createProduct(productDto: any): Promise<Product> {
    try {
      const newProduct = this.productRepository.create(productDto as Partial<Product>);
      return await this.productRepository.save(newProduct);
    } catch (error: any) {
      throw new InternalServerErrorException('Failed to create product', error.message);
    }
  }

  // Get reviews for a specific product
  async getProductReviews(productId: string): Promise<Review[]> {
    try {
      return await this.reviewRepository.find({
        where: { productId },
        order: { createdAt: 'DESC' },
      });
    } catch (error: any) {
      throw new InternalServerErrorException('Failed to fetch reviews', error.message);
    }
  }

  // Add a new review
  async addReview(reviewDto: any): Promise<Review> {
    try {
      const newReview = this.reviewRepository.create(reviewDto as Partial<Review>);
      return await this.reviewRepository.save(newReview);
    } catch (error: any) {
      throw new InternalServerErrorException('Failed to add review', error.message);
    }
  }

  // Submit and save an order from the App's Cart
  async submitOrder(orderDto: any): Promise<Order> {
    try {
      const newOrder = this.orderRepository.create(orderDto as Partial<Order>);
      return await this.orderRepository.save(newOrder);
    } catch (error: any) {
      throw new InternalServerErrorException('Failed to submit order', error.message);
    }
  }
}
