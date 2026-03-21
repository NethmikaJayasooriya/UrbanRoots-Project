import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

const TEST_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class SellerService {
  constructor(private readonly supabase: SupabaseService) {}

  async getSeller() {
    const { data, error } = await this.supabase.client
      .from('sellers')
      .select('*')
      .eq('user_id', TEST_USER_ID)
      .maybeSingle();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  async startOnboarding() {
    const existing = await this.getSeller();

    if (existing) {
      return existing;
    }

    const { data, error } = await this.supabase.client
      .from('sellers')
      .insert({
        user_id: TEST_USER_ID,
        onboarding_step: 'identity',
        is_verified: false,
        shop_name: null,
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

  async completeIdentity() {
    const existing = await this.getSeller();

    if (!existing) {
      return this.startOnboarding();
    }

    const { data, error } = await this.supabase.client
      .from('sellers')
      .update({
        is_verified: true,
        onboarding_step: 'shop',
      })
      .eq('user_id', TEST_USER_ID)
      .select('*')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  async updateShopDetails(shop_name: string, shop_description: string) {
    const existing = await this.getSeller();

    if (!existing) {
      await this.startOnboarding();
    }

    const { data, error } = await this.supabase.client
      .from('sellers')
      .update({
        shop_name,
        shop_description,
        onboarding_step: 'payout',
      })
      .eq('user_id', TEST_USER_ID)
      .select('*')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  async setPayout(method: string) {
    const existing = await this.getSeller();

    if (!existing) {
      await this.startOnboarding();
    }

    const { data, error } = await this.supabase.client
      .from('sellers')
      .update({
        payout_method: method,
        onboarding_step: 'completed',
      })
      .eq('user_id', TEST_USER_ID)
      .select('*')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }
}
