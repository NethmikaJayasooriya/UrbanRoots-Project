import { Controller, Post, Body, HttpCode, HttpStatus, BadRequestException } from '@nestjs/common';
import { OtpService } from './otp.service';

@Controller('otp')
export class OtpController {
  constructor(private readonly otpService: OtpService) { }

  @Post('generate')
  @HttpCode(HttpStatus.OK)
  async generateOtp(@Body('email') email: string) {
    if (!email) {
      throw new BadRequestException('Email is required');
    }
    await this.otpService.generateAndSendOtp(email);
    return { success: true, message: 'OTP sent to email' };
  }

  @Post('verify')
  @HttpCode(HttpStatus.OK)
  async verifyOtp(@Body('email') email: string, @Body('otp') otp: string) {
    if (!email || !otp) {
      throw new BadRequestException('Email and OTP are required');
    }
    const isValid = await this.otpService.verifyOtp(email, otp);
    return { success: isValid, message: isValid ? 'OTP verified' : 'Invalid OTP' };
  }
}
