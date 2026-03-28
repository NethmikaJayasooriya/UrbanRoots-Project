import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';
import { MarketplaceService } from '../marketplace/marketplace.service';

@Injectable()
export class SellerService {
  constructor(
    private readonly supabase: SupabaseService,
    private readonly marketplaceService: MarketplaceService,
  ) {}

  /**
   * Compute this seller's average rating by:
   * 1. Fetching all product IDs belonging to the seller
   * 2. Fetching all reviews for those products
   * 3. Averaging the review ratings
   *
   * This is done directly via Supabase so it is schema-agnostic
   * and does not depend on TypeORM's rating column being in sync.
   */
  private async computeRatingForSeller(sellerId: string): Promise<number> {
    // 1. Get all product IDs for this seller
    const { data: products, error: prodErr } = await this.supabase.client
      .from('products')
      .select('id')
      .eq('seller_id', sellerId);

    if (prodErr || !products || products.length === 0) return 0;

    const productIds = products.map((p: any) => p.id);

    // 2. Get all reviews for those products
    const { data: reviews, error: revErr } = await this.supabase.client
      .from('reviews')
      .select('rating')
      .in('productId', productIds);

    if (revErr || !reviews || reviews.length === 0) return 0;

    // 3. Average
    const total = reviews.reduce((sum: number, r: any) => sum + Number(r.rating), 0);
    return parseFloat((total / reviews.length).toFixed(2));
  }

  async getSeller(uid: string) {
    const { data, error } = await this.supabase.client
      .from('sellers')
      .select('*')
      .eq('uid', uid)
      .maybeSingle();

    if (error) {
      throw new Error(error.message);
    }

    if (data) {
      // Compute the rating directly from reviews (reliable, schema-agnostic)
      const computedRating = await this.computeRatingForSeller(data.id).catch(() => 0);

      // Also try to persist the computed rating back into the sellers table
      // so the TypeORM-based endpoints stay in sync too (best-effort).
      (async () => {
        try {
          await this.supabase.client
            .from('sellers')
            .update({ rating: computedRating })
            .eq('id', data.id);
        } catch (e: any) {
          console.error(`Failed to persist computed rating for seller ${data.id}:`, e);
        }
      })();

      // Inject the computed rating into the returned object
      return { ...data, rating: computedRating };
    }

    return data;
  }

  async startOnboarding(uid: string) {
    const existing = await this.getSeller(uid);

    if (existing) {
      return existing;
    }

    const { data, error } = await this.supabase.client
      .from('sellers')
      .insert({
        uid: uid,
        onboarding_step: 'identity',
        is_verified: false,
        brand_name: null,
        shop_description: null,
        payout_method: null,
      })
      .select('*')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  async completeIdentity(uid: string) {
    const existing = await this.getSeller(uid);

    if (!existing) {
      return this.startOnboarding(uid);
    }

    const { data, error } = await this.supabase.client
      .from('sellers')
      .update({
        is_verified: true,
        onboarding_step: 'shop',
      })
      .eq('uid', uid)
      .select('*')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  async updateShopDetails(uid: string, shop_name: string, shop_description: string) {
    const existing = await this.getSeller(uid);

    if (!existing) {
      await this.startOnboarding(uid);
    }

    const { data, error } = await this.supabase.client
      .from('sellers')
      .update({
        brand_name: shop_name,
        shop_description,
        onboarding_step: 'payout',
      })
      .eq('uid', uid)
      .select('*')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  async setPayout(uid: string, method: string) {
    const existing = await this.getSeller(uid);

    if (!existing) {
      await this.startOnboarding(uid);
    }

    const { data, error } = await this.supabase.client
      .from('sellers')
      .update({
        payout_method: method,
        onboarding_step: 'completed',
      })
      .eq('uid', uid)
      .select('*')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }
}
