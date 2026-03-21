import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, FindOptionsWhere } from 'typeorm';
import { Sale } from './entities/sale.entity';

@Injectable()
export class SalesService {
  constructor(
    @InjectRepository(Sale)
    private readonly repo: Repository<Sale>,
  ) {}

  /**
   * GET /sales?seller_id=X&from=ISO&to=ISO
   *
   * Returns sales with the joined product (name + image_url).
   * Flutter's Sale.fromJson expects:
   *   { ...saleFields, product: { name, image_url } }
   */
  async findBySeller(
    sellerId: string,
    from?: string,
    to?: string,
  ): Promise<any[]> {
    const where: FindOptionsWhere<Sale> = { seller_id: sellerId };

    if (from && to) {
      where.sale_date = Between(new Date(from), new Date(to));
    }

    const sales = await this.repo.find({
      where,
      relations: ['product'],          // loads the product row via JOIN
      order: { sale_date: 'DESC' },
    });

    // Shape the response to match what Flutter expects
    return sales.map((s) => ({
      id:         s.id,
      product_id: s.product_id,
      seller_id:  s.seller_id,
      quantity:   s.quantity,
      unit_price: s.unit_price,
      total:      s.total,
      sale_date:  s.sale_date,
      created_at: s.created_at,
      product: {
        name:      s.product?.name      ?? 'Unknown Product',
        image_url: s.product?.image_url ?? '',
      },
    }));
  }
}
