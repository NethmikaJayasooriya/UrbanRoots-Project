import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

const VALID_PLANS = ['weekly', 'monthly', 'annual'];
const VALID_PAYMENT_METHODS = ['card', 'paypal', 'apple_pay', 'google_pay'];

const DEFAULT_SUBSCRIPTION = {
  selected_plan: 'monthly',
  status: 'inactive',
  payment_status: 'pending',
  payment_method: null,
  started_at: null,
  expires_at: null,
};

@Injectable()
export class SubscriptionsService {
  constructor(private readonly supabase: SupabaseService) {}

  async getMySubscription(uid: string) {
    const { data, error } = await this.supabase.client
      .from('subscriptions')
      .select('*')
      .eq('user_id', uid)
      .maybeSingle();

    if (error) {
      console.warn(`[Subscriptions] select error for ${uid}: ${error.message}`);
      return { user_id: uid, ...DEFAULT_SUBSCRIPTION };
    }

    if (data) return data;

    const { data: created, error: createError } = await this.supabase.client
      .from('subscriptions')
      .insert({ user_id: uid, ...DEFAULT_SUBSCRIPTION })
      .select('*')
      .single();

    if (createError) {
      console.warn(`[Subscriptions] insert failed for ${uid}: ${createError.message}`);
      return { user_id: uid, ...DEFAULT_SUBSCRIPTION };
    }

    return created;
  }

  private getPlanAmount(plan: string): number {
    switch (plan) {
      case 'weekly': return 4.99;
      case 'monthly': return 12.99;
      case 'annual': return 99.99;
      default: throw new Error('Invalid subscription plan');
    }
  }

  private getExpiryDate(plan: string): string {
    const date = new Date();
    switch (plan) {
      case 'weekly': date.setDate(date.getDate() + 7); break;
      case 'monthly': date.setMonth(date.getMonth() + 1); break;
      case 'annual': date.setFullYear(date.getFullYear() + 1); break;
      default: throw new Error('Invalid subscription plan');
    }
    return date.toISOString();
  }

  async startMembership(uid: string, body: { selectedPlan: string; paymentMethod: string }) {
    const { selectedPlan, paymentMethod } = body;

    if (!VALID_PLANS.includes(selectedPlan)) throw new Error('Invalid subscription plan');
    if (!VALID_PAYMENT_METHODS.includes(paymentMethod)) throw new Error('Invalid payment method');

    const existing = await this.getMySubscription(uid);
    const now = new Date().toISOString();
    const expiresAt = this.getExpiryDate(selectedPlan);
    const amount = this.getPlanAmount(selectedPlan);

    const { data: updatedSubscription, error: updateError } =
      await this.supabase.client
        .from('subscriptions')
        .update({
          selected_plan: selectedPlan,
          payment_method: paymentMethod,
          payment_status: 'paid',
          status: 'active',
          started_at: now,
          expires_at: expiresAt,
          updated_at: now,
        })
        .eq('user_id', uid)
        .select('*')
        .single();

    if (updateError) throw new Error(updateError.message);

    const { data: payment, error: paymentError } = await this.supabase.client
      .from('subscription_payments')
      .insert({
        user_id: uid,
        subscription_id: existing['id'],
        selected_plan: selectedPlan,
        payment_method: paymentMethod,
        amount,
        currency: 'USD',
        payment_status: 'paid',
        updated_at: now,
      })
      .select('*')
      .single();

    if (paymentError) throw new Error(paymentError.message);

    return {
      subscription: updatedSubscription,
      payment,
      message: 'Pro membership activated successfully',
    };
  }
}
