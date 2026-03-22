import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';
import { CreateReviewDto } from './dto/create-review.dto';

@Injectable()
export class ReviewsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async upsertReview(uid: string, dto: CreateReviewDto) {
    const cleanedFeedback =
      dto.feedbackText && dto.feedbackText.trim().length > 0
        ? dto.feedbackText.trim()
        : null;

    const { data, error } = await this.supabaseService.client
      .from('app_reviews')
      .upsert(
        {
          user_id: uid,
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
      throw new BadRequestException(error.message);
    }

    return data;
  }

  async getMyReview(uid: string) {
    const { data, error } = await this.supabaseService.client
      .from('app_reviews')
      .select('*')
      .eq('user_id', uid)
      .maybeSingle();

    if (error) {
      throw new BadRequestException(error.message);
    }

    return data;
  }
}
