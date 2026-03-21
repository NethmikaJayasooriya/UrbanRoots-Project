import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

const TEST_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class StreaksService {
  constructor(private readonly supabase: SupabaseService) {}

  private getTodayDateString(): string {
    return new Date().toISOString().split('T')[0];
  }

  private getYesterdayDateString(): string {
    const date = new Date();
    date.setDate(date.getDate() - 1);
    return date.toISOString().split('T')[0];
  }

  async getOrCreateStreak() {
    const { data, error } = await this.supabase.client
      .from('streaks')
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
      .from('streaks')
      .insert({
        user_id: TEST_USER_ID,
        current_streak: 0,
        longest_streak: 0,
        last_completed_date: null,
      })
      .select('*')
      .single();

    if (createError) {
      throw new Error(createError.message);
    }

    return created;
  }

  async getMyStreak() {
    const streak = await this.getOrCreateStreak();

    const today = this.getTodayDateString();
    const yesterday = this.getYesterdayDateString();

    if (
      streak.last_completed_date != null &&
      streak.last_completed_date !== today &&
      streak.last_completed_date !== yesterday &&
      streak.current_streak !== 0
    ) {
      const { data, error } = await this.supabase.client
        .from('streaks')
        .update({
          current_streak: 0,
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

    return streak;
  }

  async completeToday() {
    const streak = await this.getOrCreateStreak();

    const today = this.getTodayDateString();
    const yesterday = this.getYesterdayDateString();

    if (streak.last_completed_date === today) {
      return {
        ...streak,
        alreadyCompletedToday: true,
      };
    }

    let nextStreak = 1;

    if (streak.last_completed_date === yesterday) {
      nextStreak = streak.current_streak + 1;
    }

    const nextLongest =
      nextStreak > streak.longest_streak ? nextStreak : streak.longest_streak;

    const { data, error } = await this.supabase.client
      .from('streaks')
      .update({
        current_streak: nextStreak,
        longest_streak: nextLongest,
        last_completed_date: today,
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', TEST_USER_ID)
      .select('*')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return {
      ...data,
      alreadyCompletedToday: false,
    };
  }
}
