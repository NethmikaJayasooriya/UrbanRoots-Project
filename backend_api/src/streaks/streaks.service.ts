import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

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

  async getOrCreateStreak(uid: string) {
    const { data, error } = await this.supabase.client
      .from('streaks')
      .select('*')
      .eq('user_id', uid)
      .maybeSingle();

    if (error) {
      console.warn(`[Streaks] select error for ${uid}: ${error.message}`);
      return this.defaultStreak(uid);
    }

    if (data) return data;

    // Try to create a streak row.
    const { data: created, error: createError } = await this.supabase.client
      .from('streaks')
      .insert({
        user_id: uid,
        current_streak: 0,
        longest_streak: 0,
        last_completed_date: null,
      })
      .select('*')
      .single();

    if (createError) {
      console.warn(`[Streaks] insert failed for ${uid}: ${createError.message}`);
      return this.defaultStreak(uid);
    }

    return created;
  }

  private defaultStreak(uid: string) {
    return {
      user_id: uid,
      current_streak: 0,
      longest_streak: 0,
      last_completed_date: null,
    };
  }

  async getMyStreak(uid: string) {
    const streak = await this.getOrCreateStreak(uid);

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
        .update({ current_streak: 0, updated_at: new Date().toISOString() })
        .eq('user_id', uid)
        .select('*')
        .single();

      if (error) {
        return { ...streak, current_streak: 0 };
      }
      return data;
    }

    return streak;
  }

  async completeToday(uid: string) {
    const streak = await this.getOrCreateStreak(uid);

    const today = this.getTodayDateString();
    const yesterday = this.getYesterdayDateString();

    if (streak.last_completed_date === today) {
      return { ...streak, alreadyCompletedToday: true };
    }

    let nextStreak = 1;
    if (streak.last_completed_date === yesterday) {
      nextStreak = streak.current_streak + 1;
    }

    const nextLongest =
      nextStreak > (streak.longest_streak ?? 0) ? nextStreak : streak.longest_streak;

    const { data, error } = await this.supabase.client
      .from('streaks')
      .update({
        current_streak: nextStreak,
        longest_streak: nextLongest,
        last_completed_date: today,
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', uid)
      .select('*')
      .single();

    if (error) {
      // Return in-memory result even if DB couldn't persist
      console.warn(`[Streaks] update failed for ${uid}: ${error.message}`);
      return { ...streak, current_streak: nextStreak, alreadyCompletedToday: false };
    }

    return { ...data, alreadyCompletedToday: false };
  }
}
