import {
  Injectable, NotFoundException, ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from './entities/product.entity';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly repo: Repository<Product>,
  ) {}

  /** GET /products?seller_id=X */
  async findBySeller(sellerId: string): Promise<Product[]> {
    return this.repo.find({
      where: { seller_id: sellerId },
      order: { created_at: 'DESC' },
    });
  }

  /** GET /products/:id */
  async findOne(id: string): Promise<Product> {
    const product = await this.repo.findOneBy({ id });
    if (!product) throw new NotFoundException(`Product ${id} not found`);
    return product;
  }

  /** POST /products */
  async create(dto: CreateProductDto): Promise<Product> {
    const product = this.repo.create({
      ...dto,
      is_active: dto.is_active ?? true,
    });
    return this.repo.save(product);
  }

  /** PATCH /products/:id */
  async update(id: string, dto: UpdateProductDto): Promise<Product> {
    const product = await this.findOne(id);
    Object.assign(product, dto);
    return this.repo.save(product);
  }

  /** PATCH /products/:id/toggle-active */
  async toggleActive(id: string): Promise<Product> {
    const product = await this.findOne(id);
    product.is_active = !product.is_active;
    return this.repo.save(product);
  }

  /** DELETE /products/:id */
  async remove(id: string): Promise<void> {
    const product = await this.findOne(id);

    // Check if this product has sales — ON DELETE RESTRICT means
    // the DB will reject it anyway, but we give a cleaner error
    const saleCount = await this.repo.manager
      .getRepository('sales')
      .count({ where: { product_id: id } })
      .catch(() => 0);

    if (saleCount > 0) {
      throw new ConflictException(
        'Cannot delete a product that has sales records.',
      );
    }

    await this.repo.remove(product);
  }
}
