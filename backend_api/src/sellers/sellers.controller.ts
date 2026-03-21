import {
  Controller, Get, Post, Patch,
  Param, Body, HttpCode, HttpStatus,
} from '@nestjs/common';
import { SellersService } from './sellers.service';
import { CreateSellerDto } from './dto/create-seller.dto';
import { UpdateSellerDto } from './dto/update-seller.dto';

@Controller('sellers')
export class SellersController {
  constructor(private readonly service: SellersService) {}

  /** GET /sellers/:id */
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findById(id);
  }

  /** POST /sellers — create seller during onboarding */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() dto: CreateSellerDto) {
    return this.service.create(dto);
  }

  /** PATCH /sellers/:id — update business + payment details */
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateSellerDto) {
    return this.service.update(id, dto);
  }
}
