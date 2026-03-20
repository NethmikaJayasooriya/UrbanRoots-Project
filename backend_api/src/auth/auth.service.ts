import { BadRequestException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { OtpService } from '../otp/otp.service';
import { UserService } from '../user/user.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly otpService: OtpService,
    private readonly firebaseService: FirebaseService,
    // INJECT OUR NEW USER SERVICE INSTEAD!
    private readonly userService: UserService,
  ) {}

  /**
   * Request OTP for Login
   */
  async requestLoginOtp(email: string): Promise<void> {
    try {
      await this.firebaseService.auth.getUserByEmail(email);
      await this.otpService.generateAndSendOtp(email);
      this.logger.log(`Login OTP sent to ${email}`);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        throw new NotFoundException('No account found with this email. Please sign up first.');
      }
      throw new BadRequestException('Failed to initiate login. Please check the email.');
    }
  }

  /**
   * Request OTP for Sign Up
   */
  async requestSignupOtp(email: string): Promise<void> {
    try {
      await this.firebaseService.auth.getUserByEmail(email);
      await this.otpService.generateAndSendOtp(email);
      this.logger.log(`Signup OTP sent to existing user ${email} (continuing flow)`);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        await this.otpService.generateAndSendOtp(email);
        this.logger.log(`Signup OTP sent to new user ${email}`);
      } else {
        throw new BadRequestException('Failed to initiate signup.');
      }
    }
  }

  /**
   * Request OTP for Password Reset
   */
  async requestPasswordResetOtp(email: string): Promise<void> {
    try {
      await this.firebaseService.auth.getUserByEmail(email);
      await this.otpService.generateAndSendOtp(email);
      this.logger.log(`Password reset OTP sent to ${email}`);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        throw new NotFoundException('No account found with this email.');
      }
      throw new BadRequestException('Failed to initiate password reset.');
    }
  }

  async verifyOtp(email: string, otp: string): Promise<boolean> {
    return this.otpService.verifyOtp(email, otp);
  }

  async syncUserToFirestore(uid: string, email: string, provider: string): Promise<void> {
    try {
      const userRef = this.firebaseService.firestore.collection('users').doc(uid);
      await userRef.set(
        {
          email: email,
          authProvider: provider,
          createdAt: new Date(),
        },
        { merge: true }
      );
      this.logger.log(`User synced to Firestore: ${uid}`);

      await this.syncUserToSupabase(uid, email, provider);
    } catch (error) {
      this.logger.error(`Error syncing user to Firestore: ${error.message}`);
      throw error;
    }
  }

  /**
   * Sync a user to Supabase after successful authentication.
   */
  async syncUserToSupabase(
    uid: string,
    email: string,
    authProvider?: string,
    firstName?: string,
    lastName?: string,
    profilePicUrl?: string,
  ): Promise<void> {
    try {
      // ROUTE THIS THROUGH OUR NEW TYPEORM FUNCTION
      await this.userService.updateProfile(uid, {
        email,
        authProvider: authProvider || 'email/password',
        firstName,
        lastName,
        profilePic: profilePicUrl,
      });
      this.logger.log(`User synced to Supabase via TypeORM: ${uid}`);
    } catch (error) {
      this.logger.warn(`Supabase sync warning (non-blocking): ${error.message}`);
    }
  }

  async updatePassword(email: string, newPassword: string): Promise<void> {
    try {
      const user = await this.firebaseService.auth.getUserByEmail(email);
      await this.firebaseService.auth.updateUser(user.uid, {
        password: newPassword,
      });
      this.logger.log(`Password updated successfully for ${email}`);
    } catch (error) {
      this.logger.error(`Failed to update password for ${email}`, error.stack);
      throw new BadRequestException('Could not update password. Please try again.');
    }
  }

  isEmailRecentlyVerified(email: string): boolean {
    return this.otpService.isEmailVerified(email);
  }

  clearVerifiedEmail(email: string): void {
    this.otpService.clearVerifiedEmail(email);
  }
}