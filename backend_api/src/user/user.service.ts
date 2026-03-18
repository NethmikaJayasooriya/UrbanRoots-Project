import { Injectable, InternalServerErrorException, Logger, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';

export interface UserProfileData {
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  authProvider?: string;
  profilePic?: string;
  is_onboarded?: boolean;
}

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  constructor(private readonly firebaseService: FirebaseService) {}

  /**
   * Updates an existing user's profile in Firestore (used for setup profile and edit profile).
   */
  async updateProfile(uid: string, profileData: UserProfileData): Promise<void> {
    try {
      const userRef = this.firebaseService.firestore.collection('users').doc(uid);
      
      // Fetch existing to see if we need to set createdAt
      const doc = await userRef.get();
      const updatePayload: any = {
        ...profileData,
        updatedAt: new Date(),
      };
      
      if (!doc.exists || !doc.data()?.createdAt) {
        updatePayload.createdAt = new Date();
      }

      await userRef.set(updatePayload, { merge: true });
      
      this.logger.log(`Profile updated for user: ${uid}`);
    } catch (error) {
      this.logger.error(`Failed to update profile for user ${uid}`, error.stack);
      throw new InternalServerErrorException('Failed to update user profile in database.');
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
