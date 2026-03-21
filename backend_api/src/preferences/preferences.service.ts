import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

const TEST_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class PreferencesService {
  constructor(private readonly supabase: SupabaseService) {}

  async getMyPreferences() {
    const { data, error } = await this.supabase.client
      .from('preferences')
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
      .from('preferences')
      .insert({
        user_id: TEST_USER_ID,
        smart_reminders: true,
      })
      .select('*')
      .single();

    if (createError) {
      throw new Error(createError.message);
    }

    return created;
  }

  async updateMyPreferences(body: { smart_reminders?: boolean }) {
    await this.getMyPreferences();

    const updatePayload: Record<string, any> = {
      updated_at: new Date().toISOString(),
    };

    if (body.smart_reminders !== undefined) {
      updatePayload.smart_reminders = body.smart_reminders;
    }

    const { data, error } = await this.supabase.client
      .from('preferences')
      .update(updatePayload)
      .eq('user_id', TEST_USER_ID)
      .select('*')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }
}
