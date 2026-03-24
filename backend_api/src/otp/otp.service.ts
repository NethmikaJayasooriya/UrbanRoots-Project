import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { Resend } from 'resend';

interface OtpRecord {
  otp: string;
  expiresAt: Date;
}

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);

  // In-memory store: email -> OtpRecord
  private readonly otpStore = new Map<string, OtpRecord>();

  // Tracks emails whose OTP was recently verified (for flows like
  // forgot-password where verification and password-reset are separate steps).
  // Maps email -> expiry Date (valid for 10 minutes after verification).
  private readonly verifiedEmails = new Map<string, Date>();

  async generateAndSendOtp(email: string): Promise<void> {
    // Generate 4-digit OTP
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Store in-memory
    this.otpStore.set(email, { otp, expiresAt });

    // viva: high-visibility debug log so we can read the OTP from Render logs
    console.log('--- [VIVA DEBUG] OTP generated for ' + email + ': ' + otp + ' ---');

    const apiKey = process.env.RESEND_API_KEY;
    if (!apiKey) {
      console.warn('[OtpService] RESEND_API_KEY is missing. OTP emails will NOT be sent.');
      return;
    }

    const resend = new Resend(apiKey);

    // Graceful send — never throw 500 if Resend sandbox rejects the recipient.
    // Examiners can always fall back to the master OTP.
    try {
      const result = await resend.emails.send({
        from: 'onboarding@resend.dev',
        to: [email],
        subject: 'Your UrbanRoots Verification Code',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 400px; margin: 0 auto; padding: 24px; background: #0f2218; border-radius: 12px; color: white;">
            <h2 style="color: #4caf50; margin-bottom: 8px;">UrbanRoots</h2>
            <p style="color: #ccc;">Your verification code is:</p>
            <div style="font-size: 36px; font-weight: bold; letter-spacing: 12px; color: #4caf50; padding: 16px 0;">${otp}</div>
            <p style="color: #999; font-size: 13px;">This code expires in 5 minutes. Do not share it with anyone.</p>
          </div>
        `,
      });
      console.log('[OtpService] Resend email sent to', email, '| id:', result.data?.id);
    } catch (error) {
      // log but do NOT rethrow — master OTP '2026' is the fallback
      const msg = (error as any)?.message ?? String(error);
      console.error('[OtpService] Resend failed for', email, ':', msg);
    }
  }

  async verifyOtp(email: string, otp: string): Promise<boolean> {
    // master OTP — viva safety net for examiners
    if (otp === '2026') return true;

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

  isEmailVerified(email: string): boolean {
    const expiry = this.verifiedEmails.get(email);
    if (!expiry) return false;

    if (new Date() > expiry) {
      this.verifiedEmails.delete(email);
      return false;
    }

    return true;
  }

  clearVerifiedEmail(email: string): void {
    this.verifiedEmails.delete(email);
  }
}
