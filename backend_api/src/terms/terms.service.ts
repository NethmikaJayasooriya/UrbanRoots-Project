import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';
import { AcceptTermsDto } from './dto/accept-terms.dto';

const TEST_USER_ID = '11111111-1111-1111-1111-111111111111';
const CURRENT_TERMS_VERSION = '2026-03-01';

@Injectable()
export class TermsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async getCurrentTerms() {
    const { data, error } = await this.supabaseService.client
      .from('term_acceptances')
      .select('id, version, accepted_at')
      .eq('user_id', TEST_USER_ID)
      .eq('version', CURRENT_TERMS_VERSION)
      .maybeSingle();

    if (error) {
      throw new Error(error.message);
    }

    return {
      version: CURRENT_TERMS_VERSION,
      alreadyAccepted: data != null,
      acceptedAt: data?.accepted_at ?? null,
    };
  }

  async acceptTerms(dto: AcceptTermsDto) {
    if (!dto.version || dto.version != CURRENT_TERMS_VERSION) {
      throw new BadRequestException('Invalid terms version');
    }

    const payload = {
      user_id: TEST_USER_ID,
      version: dto.version,
      accepted_at: new Date().toISOString(),
    };

    const { data, error } = await this.supabaseService.client
      .from('term_acceptances')
      .upsert(payload, {
        onConflict: 'user_id,version',
        ignoreDuplicates: false,
      })
      .select('id, user_id, version, accepted_at')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return {
      message: 'Terms accepted successfully',
      acceptance: data,
    };
  }
}
