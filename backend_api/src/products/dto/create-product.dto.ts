import {
  IsString, IsNumber, IsBoolean,
  IsOptional, IsUUID, Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateProductDto {
  @IsUUID()
  seller_id: string;

  @IsString()
  name: string;

  @IsString()
  category: string;

  @IsOptional()
  @IsString()
  description?: string;

  @Type(() => Number)
  @IsNumber()
  @Min(0)
  price: number;

  @IsOptional()
  @IsString()
  image_url?: string;

  @IsOptional()
  @IsBoolean()
  is_active?: boolean;
}
