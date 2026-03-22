import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from '../products/entities/product.entity';
import { Review } from './entities/review.entity';
import { Order } from './entities/order.entity';

@Injectable()
export class MarketplaceService {
  constructor(
    @InjectRepository(Product) private productRepo: Repository<Product>,
    @InjectRepository(Review) private reviewRepo: Repository<Review>,
    @InjectRepository(Order) private orderRepo: Repository<Order>,
  ) {}

  async getProducts(): Promise<Product[]> {
    try {
      return await this.productRepo.find();
    } catch (error: any) {
      throw new InternalServerErrorException('Failed to fetch products', error.message);
    }
  }

  async createProduct(productDto: any): Promise<Product> {
    try {
      const newProduct = this.productRepo.create(productDto as Partial<Product>);
      return await this.productRepo.save(newProduct);
    } catch (error: any) {
      throw new InternalServerErrorException('Failed to create product', error.message);
    }
  }

  async getReviews(productId: string): Promise<Review[]> {
    return this.reviewRepo.find({
      where: { productId },
      order: { createdAt: 'DESC' },
    });
  }

  async addReview(productId: string, reviewData: any): Promise<Review> {
    const newReview = this.reviewRepo.create({
      productId,
      author: reviewData.author ?? 'User',
      rating: reviewData.rating,
      comment: reviewData.comment,
    });
    return this.reviewRepo.save(newReview);
  }

  async getRelatedProducts(productId: string): Promise<Product[]> {
    const current = await this.productRepo.findOne({ where: { id: productId } });
    if (!current) return [];
    const all = await this.productRepo.find();
    let related = all.filter(p => p.category === current.category && p.id !== productId);
    if (related.length < 3) {
      const others = all.filter(p => p.category !== current.category && p.id !== productId);
      others.sort(() => 0.5 - Math.random());
      related = [...related, ...others].slice(0, 4);
    } else {
      related = related.slice(0, 4);
    }
    return related;
  }

  async createOrder(orderData: any): Promise<{ orderId: string; status: string }> {
    const orderId = `ORD-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    const newOrder = this.orderRepo.create({
      orderId,
      customerPhone: orderData.phone,
      customerDetails: { name: orderData.name, address: orderData.address, phone: orderData.phone },
      items: orderData.items,
      totalAmount: orderData.totalAmount,
      paymentMethod: orderData.paymentMethod,
      status: 'PENDING',
    });
    await this.orderRepo.save(newOrder);
    return { orderId, status: 'PENDING' };
  }

  async handlePayHereNotification(payload: any): Promise<string> {
    const orderId = payload.order_id;
    if (payload.status_code === '2') {
      const order = await this.orderRepo.findOne({ where: { orderId } });
      if (order) {
        order.status = 'PAID';
        await this.orderRepo.save(order);
        return 'OK';
      }
    }
    return 'FAILED';
  }

  async getOrdersByPhone(phone: string): Promise<Order[]> {
    return this.orderRepo.find({
      where: { customerPhone: phone },
      order: { createdAt: 'DESC' },
    });
  }
}
