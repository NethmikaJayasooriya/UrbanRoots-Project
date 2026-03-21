import { IsString, IsUUID } from 'class-validator';

export class CreateBeneficiaryDto {
  @IsUUID()
  seller_id: string;

  @IsString()
  full_name: string;

  @IsString()
  account_number: string;

  @IsString()
  bank: string;
}
