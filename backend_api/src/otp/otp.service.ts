import {
  Injectable,
  InternalServerErrorException,
  Logger,
  BadRequestException,
} from '@nestjs/common';
import * as nodemailer from 'nodemailer';
import { ConfigService } from '@nestjs/config';

interface OtpRecord {
  otp: string;
  expiresAt: Date;
}

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);
  private transporter: nodemailer.Transporter;

  // In-memory store: email -> OtpRecord
  private readonly otpStore = new Map<string, OtpRecord>();

  // Tracks emails whose OTP was recently verified (for flows like
  // forgot-password where verification and password-reset are separate steps).
  // Maps email -> expiry Date (valid for 10 minutes after verification).
  private readonly verifiedEmails = new Map<string, Date>();

  constructor(private readonly configService: ConfigService) {
    const smtpSecure = this.configService.get<string | boolean>('SMTP_SECURE');
    const isSecure = smtpSecure === true || smtpSecure === 'true';

    this.transporter = nodemailer.createTransport({
      host: this.configService.get<string>('SMTP_HOST'),
      port: this.configService.get<number>('SMTP_PORT'),
      secure: isSecure,
      family: 4,
      auth: {
        user: this.configService.get<string>('SMTP_USER'),
        pass: this.configService.get<string>('SMTP_PASS'),
      },
      tls: {
        rejectUnauthorized: false,
      },
    } as any);
  }

  async generateAndSendOtp(email: string): Promise<void> {
    // Generate 4-digit OTP
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Store in-memory
    this.otpStore.set(email, { otp, expiresAt });

    try {
      await this.transporter.sendMail({
        from: `"UrbanRoots" <${this.configService.get<string>('SMTP_USER')}>`,
        to: email,
        subject: 'Your UrbanRoots Verification Code',
        text: `Your OTP is: ${otp}. It will expire in 5 minutes.`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 400px; margin: 0 auto; padding: 24px; background: #0f2218; border-radius: 12px; color: white;">
            <h2 style="color: #4caf50; margin-bottom: 8px;">UrbanRoots</h2>
            <p style="color: #ccc;">Your verification code is:</p>
            <div style="font-size: 36px; font-weight: bold; letter-spacing: 12px; color: #4caf50; padding: 16px 0;">${otp}</div>
            <p style="color: #999; font-size: 13px;">This code expires in 5 minutes. Do not share it with anyone.</p>
          </div>
        `,
      });
      this.logger.log(`OTP sent to ${email}`);
    } catch (error) {
      this.logger.error(`Failed to send email to ${email}`, error.stack);
      throw new InternalServerErrorException(
        'Failed to send OTP email. Please check your SMTP settings.',
      );
    }
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
