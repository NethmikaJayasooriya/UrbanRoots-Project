import {
  IsBoolean,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class CreateReviewDto {
  @IsInt()
  @Min(1)
  @Max(5)
  stars: number;

  @IsBoolean()
  hasFeedback: boolean;

  @IsOptional()
  @IsString()
  feedbackText?: string;
}
