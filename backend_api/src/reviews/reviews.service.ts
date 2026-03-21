import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';
import { CreateReviewDto } from './dto/create-review.dto';

const TEST_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class ReviewsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async upsertReview(dto: CreateReviewDto) {
    const cleanedFeedback =
      dto.feedbackText && dto.feedbackText.trim().length > 0
        ? dto.feedbackText.trim()
        : null;

    const { data, error } = await this.supabaseService.client
      .from('app_reviews')
      .upsert(
        {
          user_id: TEST_USER_ID,
          stars: dto.stars,
          has_feedback: cleanedFeedback !== null,
          feedback_text: cleanedFeedback,
          updated_at: new Date().toISOString(),
        },
        {
          onConflict: 'user_id',
        },
      )
      .select()
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }

  async getMyReview() {
    const { data, error } = await this.supabaseService.client
      .from('app_reviews')
      .select('*')
      .eq('user_id', TEST_USER_ID)
      .maybeSingle();

    if (error) {
      throw new Error(error.message);
    }

    return data;
  }
}
