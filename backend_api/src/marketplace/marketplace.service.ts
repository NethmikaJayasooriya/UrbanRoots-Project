import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from './entities/product.entity';
import { Review } from './entities/review.entity';
import { Order } from './entities/order.entity';

@Injectable()
export class MarketplaceService implements OnModuleInit {
  constructor(
    @InjectRepository(Product) private productRepo: Repository<Product>,
    @InjectRepository(Review) private reviewRepo: Repository<Review>,
    @InjectRepository(Order) private orderRepo: Repository<Order>,
  ) {}

  async onModuleInit() {
    const count = await this.productRepo.count();
    if (count === 0) {
      console.log('Seeding initial products into PostgreSQL...');
      const initialProducts = [
        { name: 'Tomato Seeds', category: 'Seeds', price: 250.0, description: 'High-yield tomato seeds suitable for urban gardens.', imageUrl: 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'spa_rounded' },
        { name: 'Organic Fertilizer', category: 'Fertilizers', price: 900.0, description: '100% organic compost fertilizer, 2kg bag.', imageUrl: 'https://images.unsplash.com/photo-1599839619722-39751411ea63?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'eco_rounded' },
        { name: 'Indoor Fern', category: 'Indoor', price: 1200.0, description: 'Low-maintenance indoor fern for better air quality.', imageUrl: 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'local_florist_rounded' },
        { name: 'Gardening Gloves', category: 'Tools', price: 450.0, description: 'Durable, weather-resistant gardening gloves.', imageUrl: 'https://images.unsplash.com/photo-1416879598056-0cbb04922b0a?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'hardware_rounded' },
        { name: 'Watering Can', category: 'Tools', price: 850.0, description: 'Ergonomic 2L watering can with a detachable spout.', imageUrl: 'https://images.unsplash.com/photo-1585072044322-9599d1461164?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'hardware_rounded' },
        { name: 'Basil Plant', category: 'Plants', price: 350.0, description: 'Fresh basil plant, perfect for your kitchen window.', imageUrl: 'https://images.unsplash.com/photo-1608681290619-a1d2f00f0aa0?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'local_florist_rounded' },
        { name: 'Chili Seeds', category: 'Seeds', price: 150.0, description: 'Spicy Kochchi chili seeds.', imageUrl: 'https://images.unsplash.com/photo-1588015383566-1caba908be59?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'spa_rounded' },
        { name: 'Neem Oil (Pesticide)', category: 'Care', price: 650.0, description: 'Natural pest control for organic farming.', imageUrl: 'https://images.unsplash.com/photo-1611078712165-4f5195e87aed?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'spa_rounded' },
      ];
      for (const p of initialProducts) {
        await this.productRepo.save(this.productRepo.create(p));
      }
      console.log('Seeding complete!');
    }
  }

  async getProducts() {
    const products = await this.productRepo.find();
    return Promise.all(products.map(async (product) => {
      const reviews = await this.reviewRepo.find({ where: { productId: product.name } });
      const reviewCount = reviews.length;
      let averageRating = 0;
      if (reviewCount > 0) {
        averageRating = reviews.reduce((sum, r) => sum + r.rating, 0) / reviewCount;
      }
      return {
        ...product,
        rating: averageRating,
        reviewCount,
      };
    }));
  }

  async getReviews(productId: string) {
    return this.reviewRepo.find({ 
      where: { productId },
      order: { createdAt: 'DESC' }
    });
  }

  async addReview(productId: string, reviewData: any) {
    const newReview = this.reviewRepo.create({
      productId,
      originalName: 'User',
      rating: reviewData.rating,
      comment: reviewData.comment,
    });
    return this.reviewRepo.save(newReview);
  }

  async getRelatedProducts(productName: string) {
    const currentProduct = await this.productRepo.findOne({ where: { name: productName } });
    if (!currentProduct) return [];
    
    const allProducts = await this.productRepo.find();
    let related = allProducts.filter(p => p.category === currentProduct.category && p.name !== productName);
    
    if (related.length < 3) {
      const others = allProducts.filter(p => p.category !== currentProduct.category && p.name !== productName);
      others.sort(() => 0.5 - Math.random());
      related = [...related, ...others].slice(0, 4);
    } else {
      related = related.slice(0, 4);
    }
    
    return Promise.all(related.map(async (product) => {
      const reviews = await this.reviewRepo.find({ where: { productId: product.name } });
      const reviewCount = reviews.length;
      let averageRating = 0;
      if (reviewCount > 0) {
        averageRating = reviews.reduce((sum, r) => sum + r.rating, 0) / reviewCount;
      }
      return {
        ...product,
        rating: averageRating,
        reviewCount,
      };
    }));
  }

  async createOrder(orderData: any) {
    const orderId = `ORD-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    const newOrder = this.orderRepo.create({
      orderId,
      customerPhone: orderData.phone,
      customerDetails: {
        name: orderData.name,
        address: orderData.address,
        phone: orderData.phone,
      },
      items: orderData.items,
      totalAmount: orderData.totalAmount,
      paymentMethod: orderData.paymentMethod,
      status: 'PENDING',
    });
    
    await this.orderRepo.save(newOrder);
    console.log(`Order Created in Postgres: ${orderId}`);
    return { orderId, status: 'PENDING' };
  }

  async handlePayHereNotification(payload: any) {
    console.log('Received PayHere Notification:', payload);
    const orderId = payload.order_id;
    const statusCode = payload.status_code; 
    
    if (statusCode === '2') {
      const order = await this.orderRepo.findOne({ where: { orderId } });
      if (order) {
        order.status = 'PAID';
        await this.orderRepo.save(order);
        console.log(`Order ${orderId} successfully marked as PAID in Postgres!`);
        return 'OK'; 
      }
    }
    return 'FAILED';
  }

  async getOrdersByPhone(phone: string) {
    return this.orderRepo.find({
      where: { customerPhone: phone },
      order: { createdAt: 'DESC' },
    });
  }
}

