import { Body, Controller, Get, Post, Headers, UnauthorizedException } from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';

@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  private extractUid(uid?: string): string {
    if (!uid) throw new UnauthorizedException('x-user-id header is required');
    return uid;
  }

  @Get('me')
  getMyReview(@Headers('x-user-id') uid: string) {
    return this.reviewsService.getMyReview(this.extractUid(uid));
  }

  @Post()
  upsertReview(@Headers('x-user-id') uid: string, @Body() dto: CreateReviewDto) {
    return this.reviewsService.upsertReview(this.extractUid(uid), dto);
  }
}
