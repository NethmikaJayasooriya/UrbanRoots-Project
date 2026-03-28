import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';
import { MarketplaceService } from '../marketplace/marketplace.service';

@Injectable()
export class SellerService {
  constructor(
    private readonly supabase: SupabaseService,
    private readonly marketplaceService: MarketplaceService,
  ) {}

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
      // Force a rating sync using the rating engine
      await this.marketplaceService.updateSellerRating(data.id).catch(e => {
        console.error(`Sync error for singular UID ${uid}:`, e);
      });
      
      // Return fresh data with the updated rating
      const { data: freshData } = await this.supabase.client
        .from('sellers')
        .select('*')
        .eq('uid', uid)
        .maybeSingle();
        
      return freshData;
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
