import { IsString, IsEmail, IsOptional } from 'class-validator';

export class CreateSellerDto {
  @IsString()
  uid: string;

  @IsString()
  brand_name: string;

  @IsEmail()
  business_email: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  business_address?: string;

  @IsOptional()
  @IsString()
  logo_url?: string;
}
