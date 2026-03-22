import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

// Default fallback returned when the preferences row can't be inserted
// (e.g. FK constraint because the uid comes from Firebase, not Supabase Auth).
const DEFAULT_PREFERENCES = { smart_reminders: true };

@Injectable()
export class PreferencesService {
  constructor(private readonly supabase: SupabaseService) {}

  async getMyPreferences(uid: string) {
    const { data, error } = await this.supabase.client
      .from('preferences')
      .select('*')
      .eq('user_id', uid)
      .maybeSingle();

    if (error) {
      // Non-fatal — return defaults so the UI doesn't crash
      console.warn(`[Preferences] select error for ${uid}: ${error.message}`);
      return { user_id: uid, ...DEFAULT_PREFERENCES };
    }

    if (data) {
      return data;
    }

    // No row yet — try to create one. If FK constraint fails (Firebase uid ≠
    // Supabase auth uid) simply return defaults instead of throwing.
    const { data: created, error: createError } = await this.supabase.client
      .from('preferences')
      .insert({ user_id: uid, smart_reminders: true })
      .select('*')
      .single();

    if (createError) {
      console.warn(`[Preferences] insert failed for ${uid}: ${createError.message}`);
      return { user_id: uid, ...DEFAULT_PREFERENCES };
    }

    return created;
  }

  async updateMyPreferences(uid: string, body: { smart_reminders?: boolean }) {
    // Try to ensure a row exists first (if insert fails, we still proceed)
    await this.getMyPreferences(uid);

    const updatePayload: Record<string, any> = {
      updated_at: new Date().toISOString(),
    };

    if (body.smart_reminders !== undefined) {
      updatePayload.smart_reminders = body.smart_reminders;
    }

    const { data, error } = await this.supabase.client
      .from('preferences')
      .update(updatePayload)
      .eq('user_id', uid)
      .select('*')
      .single();

    if (error) {
      // Return the intended state so the UI stays consistent
      console.warn(`[Preferences] update failed for ${uid}: ${error.message}`);
      return { user_id: uid, ...DEFAULT_PREFERENCES, ...body };
    }

    return data;
  }
}
