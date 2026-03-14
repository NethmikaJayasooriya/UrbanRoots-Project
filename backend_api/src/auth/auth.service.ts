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
      await this.firebaseService.auth.getUserByEmail(email);
      // If successful, user already exists
      throw new BadRequestException('An account with this email already exists. Please log in.');
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        // User does not exist, send OTP for signup
        await this.otpService.generateAndSendOtp(email);
        this.logger.log(`Signup OTP sent to ${email}`);
      } else {
        // Rethrow the BadRequestException if it was the "already exists" error
        if (error instanceof BadRequestException) throw error;
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
}
