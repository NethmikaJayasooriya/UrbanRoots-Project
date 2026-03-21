import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

const TEST_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class ProfileService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async getMyProfile() {
    const { data, error } = await this.supabaseService.client
      .from('profiles')
      .select('*')
      .eq('user_id', TEST_USER_ID)
      .single();

    if (error) throw new Error(error.message);

    return data;
  }

  async updateMyProfile(dto: UpdateProfileDto) {
    const payload: Record<string, any> = {};

    if (dto.firstName !== undefined) payload.first_name = dto.firstName;
    if (dto.lastName !== undefined) payload.last_name = dto.lastName;
    if (dto.username !== undefined) payload.username = dto.username;
    if (dto.email !== undefined) payload.email = dto.email;
    if (dto.phone !== undefined) payload.phone = dto.phone;
    if (dto.profileImageUrl !== undefined) {
      payload.profile_image_url = dto.profileImageUrl;
    }

    const { data, error } = await this.supabaseService.client
      .from('profiles')
      .update(payload)
      .eq('user_id', TEST_USER_ID)
      .select()
      .single();

    if (error) throw new Error(error.message);

    return data;
  }
}
