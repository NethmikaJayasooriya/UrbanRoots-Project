import { Controller, Post, Body, HttpCode, HttpStatus, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login-otp')
  @HttpCode(HttpStatus.OK)
  async requestLoginOtp(@Body('email') email: string) {
    if (!email) throw new BadRequestException('Email is required');
    await this.authService.requestLoginOtp(email);
    return { success: true, message: 'OTP sent for login' };
  }

  @Post('signup-otp')
  @HttpCode(HttpStatus.OK)
  async requestSignupOtp(@Body('email') email: string) {
    if (!email) throw new BadRequestException('Email is required');
    await this.authService.requestSignupOtp(email);
    return { success: true, message: 'OTP sent for signup' };
  }

  @Post('forgot-password-otp')
  @HttpCode(HttpStatus.OK)
  async requestPasswordResetOtp(@Body('email') email: string) {
    if (!email) throw new BadRequestException('Email is required');
    await this.authService.requestPasswordResetOtp(email);
    return { success: true, message: 'OTP sent for password reset' };
  }

  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  async verifyOtp(
    @Body('email') email: string, 
    @Body('otp') otp: string,
    @Body('uid') uid?: string, // Passed from Flutter after it completes Firebase Auth
    @Body('provider') provider?: string // 'email/password' or 'google'
  ) {
    if (!email || !otp) {
      throw new BadRequestException('Email and OTP are required');
    }

    const isValid = await this.authService.verifyOtp(email, otp);
    if (!isValid) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    // If uid and provider are passed (e.g. after a valid Google SignIn or Email/Pass Signup),
    // sync base user data to Firestore.
    if (uid && provider) {
      await this.authService.syncUserToFirestore(uid, email, provider);
    }

    return { success: true, message: 'OTP verified successfully' };
  }

  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  async resetPassword(
    @Body('email') email: string,
    @Body('otp') otp: string,
    @Body('newPassword') newPassword: string,
  ) {
    if (!email || !otp || !newPassword) {
      throw new BadRequestException('Email, OTP, and new password are required');
    }

    const isValid = await this.authService.verifyOtp(email, otp);
    if (!isValid) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    await this.authService.updatePassword(email, newPassword);
    return { success: true, message: 'Password reset successfully' };
  }
}
