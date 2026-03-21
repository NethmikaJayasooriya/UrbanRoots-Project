import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { FirebaseService } from '../firebase/firebase.service';

export interface UpdateProfileDto {
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  profilePicUrl?: string;
}

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly firebaseService: FirebaseService,
  ) {}

  async updateProfile(uid: string, data: UpdateProfileDto) {
    try {
      // 1. Update Supabase (PostgreSQL)
      let user = await this.userRepository.findOne({ where: { uid } });
      if (!user) {
        // Create if it doesn't exist
        user = this.userRepository.create({ uid, ...data });
      } else {
        Object.assign(user, data);
      }
      await this.userRepository.save(user);

      // 2. Update Firestore
      const userRef = this.firebaseService.firestore.collection('users').doc(uid);
      await userRef.set({
        ...data,
        updatedAt: new Date(),
      }, { merge: true });

      this.logger.log(`Successfully synced profile for UID: ${uid} to Supabase and Firestore.`);
      return { success: true, message: 'Profile updated on both databases.' };
    } catch (error) {
      this.logger.error(`Error syncing profile for UID: ${uid}`, error.stack);
      throw new InternalServerErrorException('Failed to update profile databases.');
    }
  }
}
