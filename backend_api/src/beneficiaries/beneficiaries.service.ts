import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Beneficiary } from './entities/beneficiary.entity';
import { CreateBeneficiaryDto } from './dto/create-beneficiary.dto';

@Injectable()
export class BeneficiariesService {
  constructor(
    @InjectRepository(Beneficiary)
    private readonly repo: Repository<Beneficiary>,
  ) {}

  /** GET /beneficiaries?seller_id=X */
  async findBySeller(sellerId: string): Promise<Beneficiary[]> {
    return this.repo.find({
      where: { seller_id: sellerId },
      order: { created_at: 'ASC' },
    });
  }

  /** POST /beneficiaries */
  async create(dto: CreateBeneficiaryDto): Promise<Beneficiary> {
    const beneficiary = this.repo.create(dto);
    return this.repo.save(beneficiary);
  }

  /** DELETE /beneficiaries/:id */
  async remove(id: string): Promise<void> {
    const beneficiary = await this.repo.findOneBy({ id });
    if (!beneficiary) throw new NotFoundException(`Beneficiary ${id} not found`);
    await this.repo.remove(beneficiary);
  }
}
