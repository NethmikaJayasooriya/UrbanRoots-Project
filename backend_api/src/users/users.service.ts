import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../user/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly repo: Repository<User>,
  ) {}

  /** Mark a user as a seller after onboarding */
  async markAsSeller(uid: string): Promise<void> {
    await this.repo.update({ uid }, { is_seller: true, is_onboarded: true });
  }

  async findOne(uid: string): Promise<User | null> {
    return this.repo.findOneBy({ uid });
  }
}
