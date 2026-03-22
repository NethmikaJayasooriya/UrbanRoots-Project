import { Controller, Post, Body, HttpCode, HttpStatus, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login-otp')
  @HttpCode(HttpStatus.OK)
  async requestLoginOtp(@Body('email') email: string) {
    if (!email) throw new BadRequestException('Email is required');
    email = email.trim();
    await this.authService.requestLoginOtp(email);
    return { success: true, message: 'OTP sent for login' };
  }

  @Post('signup-otp')
  @HttpCode(HttpStatus.OK)
  async requestSignupOtp(@Body('email') email: string) {
    if (!email) throw new BadRequestException('Email is required');
    email = email.trim();
    await this.authService.requestSignupOtp(email);
    return { success: true, message: 'OTP sent for signup' };
  }

  @Post('forgot-password-otp')
  @HttpCode(HttpStatus.OK)
  async requestPasswordResetOtp(@Body('email') email: string) {
    if (!email) throw new BadRequestException('Email is required');
    email = email.trim();
    await this.authService.requestPasswordResetOtp(email);
    return { success: true, message: 'OTP sent for password reset' };
  }

  @Post('verify-otp')
  @HttpCode(HttpStatus.OK)
  async verifyOtp(
    @Body('email') email: string, 
    @Body('otp') otp: string,
    @Body('uid') uid?: string, // from flutter firebase auth
    @Body('provider') provider?: string // auth provider strategy
  ) {
    if (!email || !otp) {
      throw new BadRequestException('Email and OTP are required');
    }
    email = email.trim();
    otp = otp.trim();

    const isValid = await this.authService.verifyOtp(email, otp);
    if (!isValid) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    // trigger firestore sync post-auth if valid
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
    if (!email || !newPassword) {
      throw new BadRequestException('Email and new password are required');
    }
    email = email.trim();
    otp = otp?.trim();

    // check cached otp valid flag
    const isVerified = this.authService.isEmailRecentlyVerified(email);
    if (!isVerified) {
      throw new UnauthorizedException('Email not verified or session expired. Please verify OTP again.');
    }

    await this.authService.updatePassword(email, newPassword);

    // invalidate cached otp flag
    this.authService.clearVerifiedEmail(email);

    return { success: true, message: 'Password reset successfully' };
  }
}
