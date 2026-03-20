import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  BadRequestException,
} from '@nestjs/common';
import { PasswordService } from './password.service';

@Controller('password')
export class PasswordController {
  constructor(private readonly passwordService: PasswordService) {}

  // ─── Forgot Password ─────────────────────────────────────────

  /**
   * Initiates the forgot-password flow.
   * Generates a secure reset token, stores its hash in Firestore,
   * and sends the user an email with a reset link.
   */
  @Post('forgot')
  @HttpCode(HttpStatus.OK)
  async forgotPassword(@Body('email') email: string) {
    if (!email) {
      throw new BadRequestException('Email is required.');
    }

    await this.passwordService.requestPasswordReset(email);
    return {
      success: true,
      message:
        'If an account with that email exists, a password reset link has been sent.',
    };
  }

  /**
   * Validates the reset token and updates the user's password.
   */
  @Post('reset')
  @HttpCode(HttpStatus.OK)
  async resetPassword(
    @Body('email') email: string,
    @Body('token') token: string,
    @Body('newPassword') newPassword: string,
  ) {
    if (!email || !token || !newPassword) {
      throw new BadRequestException(
        'Email, token, and newPassword are all required.',
      );
    }

    if (newPassword.length < 6) {
      throw new BadRequestException(
        'Password must be at least 6 characters.',
      );
    }

    await this.passwordService.resetPasswordWithToken(
      email,
      token,
      newPassword,
    );
    return { success: true, message: 'Password has been reset successfully.' };
  }

  // ─── Utility / Dev Endpoints ──────────────────────────────────

  /**
   * Returns a bcrypt hash for the given plaintext password.
   * Useful for seeding data or manual testing.
   */
  @Post('hash')
  @HttpCode(HttpStatus.OK)
  async hashPassword(@Body('password') password: string) {
    if (!password) {
      throw new BadRequestException('password is required.');
    }

    const hash = await this.passwordService.hashPassword(password);
    return { success: true, hash };
  }

  /**
   * Verifies a plaintext password against a bcrypt hash.
   */
  @Post('verify')
  @HttpCode(HttpStatus.OK)
  async verifyPassword(
    @Body('password') password: string,
    @Body('hash') hash: string,
  ) {
    if (!password || !hash) {
      throw new BadRequestException('password and hash are required.');
    }

    const valid = await this.passwordService.verifyPassword(password, hash);
    return { success: true, valid };
  }
}
