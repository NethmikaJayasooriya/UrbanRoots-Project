<<<<<<< HEAD
import { Injectable, InternalServerErrorException, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FirebaseService } from '../firebase/firebase.service';
import { User } from './user.entity';

export interface UserProfileData {
=======
import { Injectable, InternalServerErrorException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { FirebaseService } from '../firebase/firebase.service';

export interface UpdateProfileDto {
>>>>>>> origin/Feature/profile-dashboard
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
<<<<<<< HEAD
  authProvider?: string;
  profilePic?: string;
  is_onboarded?: boolean;
  is_seller?: boolean;
=======
  profilePicUrl?: string;
>>>>>>> origin/Feature/profile-dashboard
}

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  constructor(
<<<<<<< HEAD
    private readonly firebaseService: FirebaseService,
    // Inject the Supabase User table repository
    @InjectRepository(User)
    private readonly userRepository: Repository<User>, 
  ) {}

  /**
   * Updates an existing user's profile in Firestore and PostgreSQL (Supabase)
   */
  async updateProfile(uid: string, profileData: UserProfileData): Promise<void> {
    try {
      // 1. Sync data securely to Supabase using TypeORM
      let user = await this.userRepository.findOne({ where: { uid } });
      
      // If the user doesn't exist in Supabase yet, create a new one
      if (!user) {
        user = this.userRepository.create({ uid });
      }

      // Map the incoming Flutter data to the Supabase columns
      if (profileData.firstName !== undefined) user.first_name = profileData.firstName;
      if (profileData.lastName !== undefined) user.last_name = profileData.lastName;
      if (profileData.email !== undefined) user.email = profileData.email;
      if (profileData.phone !== undefined) user.phone = profileData.phone;
      if (profileData.authProvider !== undefined) user.auth_provider = profileData.authProvider;
      if (profileData.profilePic !== undefined) user.profile_pic = profileData.profilePic;
      if (profileData.is_onboarded !== undefined) user.is_onboarded = profileData.is_onboarded;
      if (profileData.is_seller !== undefined) user.is_seller = profileData.is_seller;

      // Save to Supabase DB!
      await this.userRepository.save(user);
      this.logger.log(`Profile synced to Supabase for user: ${uid}`);

      // 2. Keep the original Firebase sync intact
      const userRef = this.firebaseService.firestore.collection('users').doc(uid);
      const doc = await userRef.get();
      const updatePayload: any = {
        ...profileData,
        updatedAt: new Date(),
      };
      
      Object.keys(updatePayload).forEach(key => {
        if (updatePayload[key] === undefined) {
          delete updatePayload[key];
        }
      });
      
      if (!doc.exists || !doc.data()?.createdAt) {
        updatePayload.createdAt = new Date();
      }

      await userRef.set(updatePayload, { merge: true });
      this.logger.log(`Profile updated for user: ${uid} in Firestore`);
      
    } catch (error) {
      this.logger.error(`Failed to update profile for user ${uid}`, error.stack);
      throw new InternalServerErrorException('Failed to update user profile. Please try again.');
    }
  }

  /**
   * Fetches the user profile from Firestore.
   */
  async getProfile(uid: string) {
    try {
      const doc = await this.firebaseService.firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw new NotFoundException('User profile not found');
      }
      return doc.data();
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      this.logger.error(`Failed to fetch profile for user ${uid}`, error.stack);
      throw new InternalServerErrorException('Failed to fetch user profile.');
    }
  }
}
=======
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
>>>>>>> origin/Feature/profile-dashboard
