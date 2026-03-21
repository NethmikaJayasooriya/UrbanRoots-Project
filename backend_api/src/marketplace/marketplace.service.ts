import { Injectable } from '@nestjs/common';

@Injectable()
export class MarketplaceService {
  private readonly products = [
    { name: 'Tomato Seeds', category: 'Seeds', price: 250.0, description: 'High-yield tomato seeds suitable for urban gardens.' },
    { name: 'Organic Fertilizer', category: 'Fertilizers', price: 900.0, description: '100% organic compost fertilizer, 2kg bag.' },
    { name: 'Indoor Fern', category: 'Indoor', price: 1200.0, description: 'Low-maintenance indoor fern for better air quality.' },
    { name: 'Gardening Gloves', category: 'Tools', price: 450.0, description: 'Durable, weather-resistant gardening gloves.' },
    { name: 'Watering Can', category: 'Tools', price: 850.0, description: 'Ergonomic 2L watering can with a detachable spout.' },
    { name: 'Basil Plant', category: 'Plants', price: 350.0, description: 'Fresh basil plant, perfect for your kitchen window.' },
    { name: 'Chili Seeds', category: 'Seeds', price: 150.0, description: 'Spicy Kochchi chili seeds.' },
    { name: 'Neem Oil (Pesticide)', category: 'Care', price: 650.0, description: 'Natural pest control for organic farming.' },
  ];

  // In-memory orders map for now.
  private readonly orders = new Map<string, any>();

  // In-memory reviews map: productId -> array of reviews
  private readonly reviews = new Map<string, any[]>();

  getProducts() {
    return this.products.map(product => {
      const productReviews = this.reviews.get(product.name) || [];
      const reviewCount = productReviews.length;
      let averageRating = 0;
      if (reviewCount > 0) {
        averageRating = productReviews.reduce((sum, r) => sum + r.rating, 0) / reviewCount;
      }
      return {
        ...product,
        rating: averageRating,
        reviewCount,
      };
    });
  }

  getReviews(productId: string) {
    return this.reviews.get(productId) || [];
  }

  addReview(productId: string, reviewData: any) {
    const productReviews = this.reviews.get(productId) || [];
    const newReview = {
      id: `REV-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      productId,
      originalName: 'User', // Placeholder since there is no auth
      ...reviewData,
      createdAt: new Date(),
    };
    productReviews.push(newReview);
    this.reviews.set(productId, productReviews);
    return newReview;
  }


  createOrder(orderData: any) {
    const orderId = `ORD-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    const newOrder = {
      orderId,
      ...orderData,
      status: 'PENDING',
      createdAt: new Date(),
    };
    this.orders.set(orderId, newOrder);
    console.log(`Order Created: ${orderId}`);
    return { orderId, status: 'PENDING' };
  }

  handlePayHereNotification(payload: any) {
    console.log('Received PayHere Notification:', payload);
    const orderId = payload.order_id;
    const statusCode = payload.status_code; 
    
    // PayHere status_code 2 means SUCCESS
    if (statusCode === '2') {
      const order = this.orders.get(orderId);
      if (order) {
        order.status = 'PAID';
        this.orders.set(orderId, order);
        console.log(`Order ${orderId} successfully marked as PAID!`);
        return 'OK'; // PayHere expects a 200 OK
      }
    }
    return 'FAILED';
  }
}
