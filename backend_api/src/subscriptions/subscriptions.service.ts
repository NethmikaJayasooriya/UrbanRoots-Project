import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

const TEST_USER_ID = '11111111-1111-1111-1111-111111111111';
const VALID_PLANS = ['weekly', 'monthly', 'annual'];

@Injectable()
export class SubscriptionsService {
  constructor(private readonly supabase: SupabaseService) {}

  async getMySubscription() {
    const { data, error } = await this.supabase.client
      .from('subscriptions')
      .select('*')
      .eq('user_id', TEST_USER_ID)
      .maybeSingle();

    if (error) {
      throw new Error(error.message);
    }

    if (data) {
      return data;
    }

    const { data: created, error: createError } = await this.supabase.client
      .from('subscriptions')
      .insert({
        user_id: TEST_USER_ID,
        selected_plan: 'monthly',
        status: 'active',
      })
      .select('*')
      .single();

    if (createError) {
      throw new Error(createError.message);
    }

    return created;
  }

  async updateMySubscription(body: { selectedPlan?: string }) {
    await this.getMySubscription();

    if (!body.selectedPlan || !VALID_PLANS.includes(body.selectedPlan)) {
      throw new Error('Invalid subscription plan');
    }

    const { data, error } = await this.supabase.client
      .from('subscriptions')
      .update({
        selected_plan: body.selectedPlan,
        updated_at: new Date().toISOString(),
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
