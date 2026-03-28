import {
  Controller, Get, Post, Patch, Delete,
  Param, Body, Query, HttpCode, HttpStatus,
  UseInterceptors, UploadedFile, BadRequestException,
  Req,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { extname } from 'path';
import { Request } from 'express';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { SupabaseService } from '../common/supabase/supabase.service';

@Controller('products')
export class ProductsController {
  constructor(
    private readonly service: ProductsService,
    private readonly supabaseService: SupabaseService,
  ) {}

  /** GET /products?seller_id=:uuid */
  @Get()
  findAll(@Query('seller_id') sellerId: string) {
    return this.service.findBySeller(sellerId);
  }

  /** GET /products/:id */
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  /** POST /products/upload */
  @Post('upload')
  @UseInterceptors(FileInterceptor('image'))
  async uploadImage(
    @UploadedFile() file: any,
  ) {
    if (!file) {
      throw new BadRequestException('Image file is required');
    }

    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = extname(file.originalname);
    const filename = `${file.fieldname}-${uniqueSuffix}${ext}`;

    const { data, error } = await this.supabaseService.client
      .storage
      .from('products')
      .upload(filename, file.buffer, {
        contentType: file.mimetype,
        upsert: false,
      });

    if (error) {
      console.error('[Supabase Upload Error]', error);
      throw new BadRequestException('Failed to upload image to Supabase');
    }

    const { data: publicUrlData } = this.supabaseService.client
      .storage
      .from('products')
      .getPublicUrl(filename);

    console.log('[DEBUG] Supabase Upload Generated URL:', publicUrlData.publicUrl, 'Original name:', file.originalname);
    return { imageUrl: publicUrlData.publicUrl };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@Body() dto: CreateProductDto) {
    console.log('[DEBUG] Product Creation Payload received:', dto);
    if (!('seller_id' in dto) || !dto['seller_id']) {
      throw new BadRequestException('seller_id is strictly required');
    }
    return this.service.create(dto);
  }

  /** PATCH /products/:id */
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateProductDto) {
    return this.service.update(id, dto);
  }

  /** PATCH /products/:id/toggle-active */
  @Patch(':id/toggle-active')
  toggleActive(@Param('id') id: string) {
    return this.service.toggleActive(id);
  }

  /** DELETE /products/:id */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }
}
