import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class ProfileService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async getMyProfile(uid: string) {
    const { data, error } = await this.supabaseService.client
      .from('users')
      .select('*')
      .eq('uid', uid)
      .maybeSingle(); // Returns null for new users — no error thrown

    if (error) {
      throw new Error(error.message);
    }

    // New users have no row yet — return an empty profile object so the
    // edit screen can open and let them fill in their details.
    if (!data) return { uid, first_name: null, last_name: null, phone: null, profile_image_url: null };

    data.profile_image_url = data.profile_pic;
    return data;
  }

  async updateMyProfile(uid: string, dto: UpdateProfileDto) {
    const payload: Record<string, any> = {};

    if (dto.firstName !== undefined) payload.first_name = dto.firstName;
    if (dto.lastName !== undefined) payload.last_name = dto.lastName;
    if (dto.email !== undefined) payload.email = dto.email;
    if (dto.phone !== undefined) payload.phone = dto.phone;
    if (dto.profileImageUrl !== undefined) {
      payload.profile_pic = dto.profileImageUrl;
    }

    const { data, error } = await this.supabaseService.client
      .from('users')
      .update(payload)
      .eq('uid', uid)
      .select()
      .maybeSingle();

    if (error && error.code !== 'PGRST116') throw new Error(error.message);
    
    // Fallback if the user does not have a profile row initially: Upsert it.
    if (!data) {
        const { data: inserted, error: insertError } = await this.supabaseService.client
          .from('users')
          .insert([{ uid: uid, ...payload }])
          .select()
          .maybeSingle();
          
        if (insertError) throw new Error(insertError.message);
        if (inserted) inserted.profile_image_url = inserted.profile_pic;
        return inserted;
    }

    if (data) data.profile_image_url = data.profile_pic;
    return data;
  }
}
