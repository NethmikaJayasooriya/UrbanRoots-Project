import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

const TEST_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class NotificationsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async getMyNotifications() {
    const { data, error } = await this.supabaseService.client
      .from('notifications')
      .select('*')
      .eq('user_id', TEST_USER_ID)
      .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);
    return data;
  }

  async markOneRead(id: string) {
    const { data, error } = await this.supabaseService.client
      .from('notifications')
      .update({ is_read: true })
      .eq('id', id)
      .eq('user_id', TEST_USER_ID)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async markAllRead() {
    const { error } = await this.supabaseService.client
      .from('notifications')
      .update({ is_read: true })
      .eq('user_id', TEST_USER_ID);

    if (error) throw new Error(error.message);

    return { message: 'All notifications marked as read' };
  }
}
