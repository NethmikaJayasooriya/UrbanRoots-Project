import { Body, Controller, Get, Post } from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';

@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Get('me')
  getMyReview() {
    return this.reviewsService.getMyReview();
  }

  @Post()
  upsertReview(@Body() dto: CreateReviewDto) {
    return this.reviewsService.upsertReview(dto);
  }
}
