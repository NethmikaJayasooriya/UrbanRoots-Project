import { IsString, IsEmail, IsOptional } from 'class-validator';

export class UpdateSellerDto {
  @IsOptional()
  @IsString()
  brand_name?: string;

  @IsOptional()
  @IsEmail()
  business_email?: string;

  @IsOptional()
  @IsString()
  phone?: string;

  @IsOptional()
  @IsString()
  business_address?: string;

  @IsOptional()
  @IsString()
  logo_url?: string;

  @IsOptional()
  @IsString()
  account_name?: string;

  @IsOptional()
  @IsString()
  account_number?: string;

  @IsOptional()
  @IsString()
  bank?: string;

  @IsOptional()
  @IsString()
  branch?: string;
}
