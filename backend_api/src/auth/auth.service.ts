import { Injectable, Logger, BadRequestException, NotFoundException } from '@nestjs/common';
import { OtpService } from '../otp/otp.service';
import { FirebaseService } from '../firebase/firebase.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly otpService: OtpService,
    private readonly firebaseService: FirebaseService,
  ) {}

  /**
   * Request OTP for Login
   */
  async requestLoginOtp(email: string): Promise<void> {
    try {
      // Check if user exists in Firebase Auth to confirm they have an account
      await this.firebaseService.auth.getUserByEmail(email);
      // Valid user, send OTP
      await this.otpService.generateAndSendOtp(email);
      this.logger.log(`Login OTP sent to ${email}`);
    } catch (error) {
      // If error.code === 'auth/user-not-found', user doesn't exist
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
      const user = await this.firebaseService.auth.getUserByEmail(email);
      
      // If user exists, they might be in the middle of signup.
      // We'll allow sending a "signup" OTP anyway, as it's used for verification.
      // If they are already fully onboarded, we could block it, but for now 
      // let's just send the OTP to avoid the "already exists" dead-end.
      await this.otpService.generateAndSendOtp(email);
      this.logger.log(`Signup OTP sent to existing user ${email} (continuing flow)`);

    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        // User does not exist, send OTP for signup
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
      // Exists, send OTP
      await this.otpService.generateAndSendOtp(email);
      this.logger.log(`Password reset OTP sent to ${email}`);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        throw new NotFoundException('No account found with this email.');
      }
      throw new BadRequestException('Failed to initiate password reset.');
    }
  }

  /**
   * Verify any OTP.
   * If valid, returns true. The frontend can then proceed based on context
   * (e.g. log the user in using custom token, proceed to setup profile, or allow password resets).
   */
  async verifyOtp(email: string, otp: string): Promise<boolean> {
    return this.otpService.verifyOtp(email, otp);
  }

  /**
   * Helper: After OTP is verified for a NEW signup or login, 
   * ensure the user's base Firestore document exists.
   */
  async syncUserToFirestore(uid: string, email: string, provider: string): Promise<void> {
    const userRef = this.firebaseService.firestore.collection('users').doc(uid);
    await userRef.set(
      {
        email: email,
        authProvider: provider,
        createdAt: new Date(),
        // We do *not* save the password here! 
        // Firebase Auth handles storing the password securely.
      },
      { merge: true } // Merge so we don't overwrite if it already exists
    );
  }

  /**
   * Directly update a user's password in Firebase Auth.
   * This should only be called after successful OTP verification.
   */
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
}
