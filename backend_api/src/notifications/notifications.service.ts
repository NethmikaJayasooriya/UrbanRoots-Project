import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

@Injectable()
export class NotificationsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async getMyNotifications(uid: string) {
    const { data, error } = await this.supabaseService.client
      .from('notifications')
      .select('*')
      .eq('user_id', uid)
      .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);
    return data;
  }

  async markOneRead(id: string, uid: string) {
    const { data, error } = await this.supabaseService.client
      .from('notifications')
      .update({ is_read: true })
      .eq('id', id)
      .eq('user_id', uid)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async markAllRead(uid: string) {
    const { error } = await this.supabaseService.client
      .from('notifications')
      .update({ is_read: true })
      .eq('user_id', uid);

    if (error) throw new Error(error.message);

    return { message: 'All notifications marked as read' };
  }
}
