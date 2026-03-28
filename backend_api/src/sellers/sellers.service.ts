import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Seller } from './entities/seller.entity';
import { CreateSellerDto } from './dto/create-seller.dto';
import { UpdateSellerDto } from './dto/update-seller.dto';
import { UsersService } from '../users/users.service';
import { MarketplaceService } from '../marketplace/marketplace.service';

@Injectable()
export class SellersService {
  constructor(
    @InjectRepository(Seller)
    private readonly repo: Repository<Seller>,
    private readonly usersService: UsersService,
    private readonly marketplaceService: MarketplaceService,
  ) {}

  async create(dto: CreateSellerDto): Promise<Seller> {
    const seller = this.repo.create(dto);
    const saved = await this.repo.save(seller);

    // Mark the user as a seller in the users table
    await this.usersService.markAsSeller(dto.uid);

    return saved;
  }

  async findById(id: string): Promise<Seller> {
    // Force a rating sync to ensure the dashboard reflects existing reviews
    await this.marketplaceService.updateSellerRating(id).catch(e => {
      console.error(`Sync error for seller ${id}:`, e);
    });

    const seller = await this.repo.findOneBy({ id });
    if (!seller) throw new NotFoundException(`Seller ${id} not found`);
    return seller;
  }

  async findByUid(uid: string): Promise<Seller | null> {
    const seller = await this.repo.findOneBy({ uid });
    if (seller) {
      // Update the stored rating from reviews
      await this.marketplaceService.updateSellerRating(seller.id).catch(e => {
        console.error(`Sync error for UID ${uid}:`, e);
      });
      // Return fresh data with the updated rating
      return this.repo.findOneBy({ uid });
    }
    return null;
  }

  async update(id: string, dto: UpdateSellerDto): Promise<Seller> {
    const seller = await this.findById(id);
    Object.assign(seller, dto);
    return this.repo.save(seller);
  }
}
