import { Controller, Get, Query } from '@nestjs/common';
import { SalesService } from './sales.service';

@Controller('sales')
export class SalesController {
  constructor(private readonly service: SalesService) {}

  /**
   * GET /sales?seller_id=:uuid&from=:iso&to=:iso
   *
   * from / to are optional — if omitted all sales are returned.
   */
  @Get()
  findAll(
    @Query('seller_id') sellerId: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    return this.service.findBySeller(sellerId, from, to);
  }
}
