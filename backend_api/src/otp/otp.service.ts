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
    const host = this.configService.get<string>('SMTP_HOST') || process.env.SMTP_HOST;
    const user = this.configService.get<string>('SMTP_USER') || process.env.SMTP_USER;
    const pass = this.configService.get<string>('SMTP_PASS') || process.env.SMTP_PASS;
    const port = Number(this.configService.get('SMTP_PORT')) || Number(process.env.SMTP_PORT) || 587;

    // IMPORTANT ENFORCEMENT for Gmail/SMTP protocols:
    // Port 465 ALWAYS requires `secure: true` (Implicit TLS).
    // Port 587 ALWAYS requires `secure: false` (STARTTLS - standard).
    const isSecure = port === 465;

    console.log(`[OtpService] SMTP Config: host=${host}, port=${port}, user=${user}, secure=${isSecure}`);

    if (!host || !user || !pass) {
      this.logger.error('⚠️  SMTP env vars missing (SMTP_HOST / SMTP_USER / SMTP_PASS).');
    }

    this.transporter = nodemailer.createTransport({
      host: host ?? 'smtp.gmail.com',
      port: port,
      secure: isSecure,       // false for 587 (STARTTLS), true for 465 (SSL)
      requireTLS: !isSecure,  // enforce STARTTLS upgrade on port 587
      family: 4,              // force IPv4 — Render can't reach Gmail via IPv6 on 465
      connectionTimeout: 10000,  // 10s — give cloud network time to connect
      greetingTimeout: 10000,    // 10s — wait for SMTP server greeting
      socketTimeout: 15000,      // 15s — max idle time after connection
      auth: {
        user: user ?? '',
        pass: pass ?? '',
      },
      tls: {
        rejectUnauthorized: false, // required on some cloud hosts (Render, Railway)
        minVersion: 'TLSv1.2',
      },
      debug: true,   // logs full SMTP handshake to console for diagnostics
      logger: false, // use console.log, not nodemailer's built-in logger
    } as any);
  }

  async generateAndSendOtp(email: string): Promise<void> {
    // Generate 4-digit OTP
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Store in-memory
    this.otpStore.set(email, { otp, expiresAt });
    console.log(`[OtpService] Generated OTP for ${email}: ${otp}`);

    // Send email asynchronously and don't block
    console.log(`[OtpService] Sending email to ${email}...`);
    this.transporter.sendMail({
      from: `"UrbanRoots" <${this.configService.get<string>('SMTP_USER') || process.env.SMTP_USER}>`,
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
    }).then((info) => {
      console.log(`[OtpService] Email sent successfully to ${email}. ID: ${info.messageId}`);
    }).catch((error) => {
      console.error(`[OtpService] FAILED to send email to ${email}:`, error);
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
