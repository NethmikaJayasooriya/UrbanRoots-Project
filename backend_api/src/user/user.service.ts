import { Injectable, InternalServerErrorException, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FirebaseService } from '../firebase/firebase.service';
import { User } from './user.entity';

export interface UpdateProfileDto {
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  authProvider?: string;
  profilePic?: string;
  is_onboarded?: boolean;
  is_seller?: boolean;
}

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly firebaseService: FirebaseService,
  ) {}

  /**
   * Updates user profile in both Supabase (Postgres) and Firestore.
   */
  async updateProfile(uid: string, data: UpdateProfileDto): Promise<void> {
    try {
      // 1. Sync to Supabase (Snake_case columns)
      let user = await this.userRepository.findOne({ where: { uid } });
      if (!user) {
        user = this.userRepository.create({ uid });
      }

      if (data.firstName !== undefined) user.first_name = data.firstName;
      if (data.lastName !== undefined) user.last_name = data.lastName;
      if (data.email !== undefined) user.email = data.email;
      if (data.phone !== undefined) user.phone = data.phone;
      if (data.authProvider !== undefined) user.auth_provider = data.authProvider;
      if (data.profilePic !== undefined) user.profile_pic = data.profilePic;
      if (data.is_onboarded !== undefined) user.is_onboarded = data.is_onboarded;
      if (data.is_seller !== undefined) user.is_seller = data.is_seller;

      await this.userRepository.save(user);

      // 2. Sync to Firestore (CamelCase fields)
      const userRef = this.firebaseService.firestore.collection('users').doc(uid);
      
      // Firestore rejects undefined values, so we filter them out
      const cleanData = Object.fromEntries(
        Object.entries(data).filter(([_, v]) => v !== undefined)
      );

      await userRef.set({
        ...cleanData,
        updatedAt: new Date(),
      }, { merge: true });

      this.logger.log(`Profile updated for user: ${uid} in both databases.`);
    } catch (error) {
      this.logger.error(`Failed to update profile for user ${uid}. Reason: ${error.message}`, error.stack);
      throw new InternalServerErrorException(`Failed to update user profile: ${error.message}`);
    }
  }

  /**
   * Fetches user profile from Firestore.
   */
  async getProfile(uid: string) {
    try {
      const doc = await this.firebaseService.firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw new NotFoundException('User profile not found');
      }
      return doc.data();
    } catch (error) {
      if (error instanceof NotFoundException) throw error;
      this.logger.error(`Failed to fetch profile for user ${uid}`, error.stack);
      throw new InternalServerErrorException('Failed to fetch user profile.');
    }
  }
}