import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Product } from '../products/entities/product.entity';
import { Review } from './entities/review.entity';
import { Order } from './entities/order.entity';
import { Seller } from '../sellers/entities/seller.entity';

@Injectable()
export class MarketplaceService {
  constructor(
    @InjectRepository(Product) private productRepo: Repository<Product>,
    @InjectRepository(Review) private reviewRepo: Repository<Review>,
    @InjectRepository(Order) private orderRepo: Repository<Order>,
    @InjectRepository(Seller) private sellerRepo: Repository<Seller>,
    private configService: ConfigService,
  ) {}

  getPayHereConfig() {
    return {
      merchantId: this.configService.get<string>('PAYHERE_MERCHANT_ID', '1234567'),
      isSandbox: this.configService.get<string>('PAYHERE_SANDBOX', 'true') === 'true',
    };
  }

  async getProducts(): Promise<Product[]> {
    try {
      return await this.productRepo.find({ where: { is_active: true } });
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
    const savedReview = await this.reviewRepo.save(newReview);

    // After adding a review, update the seller's rating
    const product = await this.productRepo.findOne({ where: { id: productId } });
    if (product?.seller_id) {
      this.updateSellerRating(product.seller_id).catch(err => {
        console.error('Failed to update seller rating:', err);
      });
    }

    return savedReview;
  }

  public async updateSellerRating(sellerId: string): Promise<void> {
    // 1. Get all products owned by this seller
    const products = await this.productRepo.find({
      where: { seller_id: sellerId },
      select: ['id'],
    });

    if (products.length === 0) return;

    const productIds = products.map(p => p.id);

    // 2. Get all reviews for all those products
    const reviews = await this.reviewRepo.find({
      where: { productId: In(productIds) },
      select: ['rating'],
    });

    if (reviews.length === 0) {
      await this.sellerRepo.update(sellerId, { rating: 0 });
      return;
    }

    // 3. Calculate average
    const totalRating = reviews.reduce((sum, r) => sum + r.rating, 0);
    const averageRating = totalRating / reviews.length;

    // 4. Update seller entity
    await this.sellerRepo.update(sellerId, { rating: parseFloat(averageRating.toFixed(2)) });
  }

  async getRelatedProducts(productId: string): Promise<Product[]> {
    const current = await this.productRepo.findOne({ where: { id: productId } });
    if (!current) return [];
    const all = await this.productRepo.find({ where: { is_active: true } });
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

  async createOrder(orderData: any, userId: string): Promise<{ orderId: string; status: string }> {
    const orderId = `ORD-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    const newOrder = this.orderRepo.create({
      orderId,
      userId,
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
    const {
      order_id: orderId,
      status_code: statusCode,
      md5sig: receivedHash,
      merchant_id: merchantId,
      payhere_amount: amount,
      payhere_currency: currency,
    } = payload;

    // 1. Verify Hash for security
    const secret = this.configService.get<string>('PAYHERE_SECRET', 'xyz123');
    const hashedSecret = crypto.createHash('md5').update(secret).digest('hex').toUpperCase();
    
    // MD5(merchant_id + order_id + payhere_amount + payhere_currency + status_code + MD5(merchant_secret).toUpperCase())
    const expectedHash = crypto.createHash('md5')
      .update(merchantId + orderId + amount + currency + statusCode + hashedSecret)
      .digest('hex')
      .toUpperCase();

    if (receivedHash !== expectedHash) {
      console.warn('PayHere notification hash mismatch!', { orderId, receivedHash, expectedHash });
      return 'INVALID_HASH';
    }

    // 2. Update Order Status
    // PayHere Status Codes: 2: Success, 0: Pending, -1: Canceled, -2: Failed
    const order = await this.orderRepo.findOne({ where: { orderId } });
    if (!order) return 'ORDER_NOT_FOUND';

    switch (statusCode) {
      case '2':
        order.status = 'PAID';
        break;
      case '0':
        order.status = 'PENDING_PAYMENT';
        break;
      case '-1':
        order.status = 'CANCELED';
        break;
      case '-2':
        order.status = 'FAILED';
        break;
    }

    await this.orderRepo.save(order);
    return 'OK';
  }

  async getOrdersByUser(userId: string, phones: string[] = []): Promise<Order[]> {
    let orders: Order[] = [];
    
    if (phones && phones.length > 0) {
      orders = await this.orderRepo.find({
        where: [
          { userId },
          { customerPhone: In(phones) }
        ],
        order: { createdAt: 'DESC' },
      });
    } else {
      orders = await this.orderRepo.find({
        where: { userId },
        order: { createdAt: 'DESC' },
      });
    }

    // Auto-migrate legacy orders that matched by device phone but are missing userId
    const legacyOrders = orders.filter(o => !o.userId);
    if (legacyOrders.length > 0) {
      for (const o of legacyOrders) {
        o.userId = userId;
      }
      await this.orderRepo.save(legacyOrders);
    }
    
    return orders;
  }

  async cancelOrder(orderId: string, userId: string): Promise<void> {
    const order = await this.orderRepo.findOne({ where: { orderId, userId } });
    if (order && (order.status === 'PENDING' || order.status === 'PENDING_PAYMENT')) {
      // In a real app, you might not want to hard delete, but for this cleanup flow:
      await this.orderRepo.remove(order);
    }
  }
}
