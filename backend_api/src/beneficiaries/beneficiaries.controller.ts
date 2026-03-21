import {
  Controller, Get, Post, Delete,
  Param, Body, Query, HttpCode, HttpStatus,
} from '@nestjs/common';
import { BeneficiariesService } from './beneficiaries.service';
import { CreateBeneficiaryDto } from './dto/create-beneficiary.dto';

@Controller('beneficiaries')
export class BeneficiariesController {
  constructor(private readonly service: BeneficiariesService) {}

  /** GET /beneficiaries?seller_id=:uuid */
  @Get()
  findAll(@Query('seller_id') sellerId: string) {
    return this.service.findBySeller(sellerId);
  }

  /** POST /beneficiaries */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() dto: CreateBeneficiaryDto) {
    return this.service.create(dto);
  }

  /** DELETE /beneficiaries/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
