import {
  Injectable,
  InternalServerErrorException,
  Logger,
  BadRequestException,
} from '@nestjs/common';
import { Resend } from 'resend';
import { ConfigService } from '@nestjs/config';

interface OtpRecord {
  otp: string;
  expiresAt: Date;
}

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);
  private resend: Resend;

  // In-memory store: email -> OtpRecord
  private readonly otpStore = new Map<string, OtpRecord>();

  // Tracks emails whose OTP was recently verified (for flows like
  // forgot-password where verification and password-reset are separate steps).
  // Maps email -> expiry Date (valid for 10 minutes after verification).
  private readonly verifiedEmails = new Map<string, Date>();

  constructor(private readonly configService: ConfigService) {
    const apiKey = this.configService.get<string>('RESEND_API_KEY') || process.env.RESEND_API_KEY;

    if (!apiKey) {
      console.warn('[OtpService] RESEND_API_KEY is missing. OTP emails will NOT be sent.');
    } else {
      console.log('[OtpService] Resend API initialized.');
    }

    this.resend = new Resend(apiKey || 're_placeholder');
  }

  async generateAndSendOtp(email: string): Promise<void> {
    // Generate 4-digit OTP
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Store in-memory
    this.otpStore.set(email, { otp, expiresAt });
    console.log(`[OtpService] Generated OTP for ${email}: ${otp}`);

    // Send email asynchronously using Resend API (HTTP port 443)
    console.log(`[OtpService] Attempting to send Resend email to ${email}...`);
    
    this.resend.emails.send({
      from: 'UrbanRoots <onboarding@resend.dev>',
      to: email,
      subject: 'Your UrbanRoots Verification Code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 400px; margin: 0 auto; padding: 24px; background: #0f2218; border-radius: 12px; color: white;">
          <h2 style="color: #4caf50; margin-bottom: 8px;">UrbanRoots</h2>
          <p style="color: #ccc;">Your verification code is:</p>
          <div style="font-size: 36px; font-weight: bold; letter-spacing: 12px; color: #4caf50; padding: 16px 0;">${otp}</div>
          <p style="color: #999; font-size: 13px;">This code expires in 5 minutes. Do not share it with anyone.</p>
        </div>
      `,
    }).then((response) => {
      if (response.error) {
        console.error(`[OtpService] Resend API Error for ${email}:`, response.error);
      } else {
        console.log(`[OtpService] Email sent successfully to ${email}. ID: ${response.data?.id}`);
      }
    }).catch((error) => {
      console.error(`[OtpService] FAILED to send Resend email to ${email}:`, error);
    });
  }

  async verifyOtp(email: string, otp: string): Promise<boolean> {
    const record = this.otpStore.get(email);

    if (!record) {
      return false;
    }

    if (new Date() > record.expiresAt) {
      this.otpStore.delete(email);
      throw new BadRequestException('OTP has expired');
    }

    if (record.otp !== otp) {
      return false;
    }

    // Clean up after successful verification
    this.otpStore.delete(email);

    // Mark this email as "recently verified" for 10 minutes
    this.verifiedEmails.set(
      email,
      new Date(Date.now() + 10 * 60 * 1000),
    );

    return true;
  }

  /**
   * Checks if an email was recently verified via OTP.
   * Used by flows like forgot-password where the reset step
   * is a separate request from the verification step.
   */
  isEmailVerified(email: string): boolean {
    const expiry = this.verifiedEmails.get(email);
    if (!expiry) return false;

    if (new Date() > expiry) {
      this.verifiedEmails.delete(email);
      return false;
    }

    return true;
  }

  /**
   * Clears the verified status for an email (call after consuming it).
   */
  clearVerifiedEmail(email: string): void {
    this.verifiedEmails.delete(email);
  }
}
