import {
  Injectable,
  Logger,
  BadRequestException,
  NotFoundException,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FirebaseService } from '../firebase/firebase.service';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import * as nodemailer from 'nodemailer';

/**
 * Handles password hashing (bcrypt), verification, and the
 * "Forgot Password" flow with secure, time-limited reset tokens
 * whose SHA-256 hashes are stored in Firestore.
 */
@Injectable()
export class PasswordService {
  private readonly logger = new Logger(PasswordService.name);
  private readonly BCRYPT_SALT_ROUNDS = 12;
  private readonly RESET_TOKEN_EXPIRY_MS = 60 * 60 * 1000; // 1 hour
  private transporter: nodemailer.Transporter;

  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly configService: ConfigService,
  ) {
    // Reuse the same SMTP config that the OTP module uses
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

  // ─── Password Hashing ───────────────────────────────────────────

  /**
   * Hash a plaintext password using bcrypt with an auto-generated salt.
   */
  async hashPassword(plaintext: string): Promise<string> {
    return bcrypt.hash(plaintext, this.BCRYPT_SALT_ROUNDS);
  }

  /**
   * Compare a plaintext password against a bcrypt hash.
   */
  async verifyPassword(plaintext: string, hash: string): Promise<boolean> {
    return bcrypt.compare(plaintext, hash);
  }

  // ─── Reset Token Helpers ────────────────────────────────────────

  /**
   * Generate a cryptographically-secure reset token.
   * Returns the raw token (sent to the user) **and** its SHA-256 hash
   * (stored in Firestore so the raw token is never persisted).
   */
  generateResetToken(): {
    token: string;
    hashedToken: string;
    expiresAt: Date;
  } {
    const token = crypto.randomBytes(32).toString('hex'); // 64-char hex
    const hashedToken = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');
    const expiresAt = new Date(Date.now() + this.RESET_TOKEN_EXPIRY_MS);

    return { token, hashedToken, expiresAt };
  }

  // ─── Forgot Password Flow ──────────────────────────────────────

  /**
   * 1. Verify the email belongs to an existing Firebase Auth user.
   * 2. Generate a secure reset token.
   * 3. Store the SHA-256 hash of the token + expiry in Firestore
   *    under `password_reset_tokens/{email}`.
   * 4. Send an email containing the reset link (simulated base URL).
   */
  async requestPasswordReset(email: string): Promise<void> {
    // Step 1 — confirm user exists
    try {
      await this.firebaseService.auth.getUserByEmail(email);
    } catch (error: any) {
      if (error.code === 'auth/user-not-found') {
        throw new NotFoundException(
          'No account found with this email address.',
        );
      }
      throw new InternalServerErrorException(
        'Could not process the password reset request.',
      );
    }

    // Step 2 — generate token
    const { token, hashedToken, expiresAt } = this.generateResetToken();

    // Step 3 — persist the *hashed* token in Firestore
    const tokenRef = this.firebaseService.firestore
      .collection('password_reset_tokens')
      .doc(email);

    await tokenRef.set({
      hashedToken,
      expiresAt: expiresAt.toISOString(),
      createdAt: new Date().toISOString(),
    });

    this.logger.log(`Password reset token stored for ${email}`);

    // Step 4 — send email with reset link
    const frontendBaseUrl =
      this.configService.get<string>('FRONTEND_RESET_URL') ||
      'https://urbanroots.app/reset-password';
    const resetLink = `${frontendBaseUrl}?token=${token}&email=${encodeURIComponent(email)}`;

    try {
      await this.transporter.sendMail({
        from: `"UrbanRoots" <${this.configService.get<string>('SMTP_USER')}>`,
        to: email,
        subject: 'Reset Your UrbanRoots Password',
        text: `You requested a password reset. Use the following link within 1 hour:\n\n${resetLink}\n\nIf you did not request this, please ignore this email.`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px; background: #0f2218; border-radius: 12px; color: white;">
            <h2 style="color: #4caf50; margin-bottom: 8px;">UrbanRoots</h2>
            <p style="color: #ccc;">You requested a password reset. Click the button below to set a new password.</p>
            <div style="text-align: center; margin: 24px 0;">
              <a href="${resetLink}"
                 style="background: #4caf50; color: white; padding: 12px 32px; border-radius: 8px; text-decoration: none; font-weight: bold; display: inline-block;">
                Reset Password
              </a>
            </div>
            <p style="color: #999; font-size: 13px;">This link expires in 1 hour. If you did not request a reset, you can safely ignore this email.</p>
            <p style="color: #666; font-size: 11px; margin-top: 16px;">Reset link: ${resetLink}</p>
          </div>
        `,
      });

      this.logger.log(`Password reset email sent to ${email}`);
    } catch (error: any) {
      this.logger.error(
        `Failed to send password reset email to ${email}`,
        error.stack,
      );
      // The token is already saved; we still throw so the caller knows
      throw new InternalServerErrorException(
        'Password reset token generated but email delivery failed. Please try again.',
      );
    }
  }

  /**
   * 1. Hash the incoming raw token with SHA-256.
   * 2. Look up every doc in `password_reset_tokens` to find one whose
   *    hashedToken matches (we key by email, so we need the email too).
   * 3. Validate expiry.
   * 4. Update the user's password in Firebase Auth.
   * 5. Delete the consumed token document.
   */
  async resetPasswordWithToken(
    email: string,
    token: string,
    newPassword: string,
  ): Promise<void> {
    // Step 1 — hash the raw token
    const hashedToken = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    // Step 2 — look up the stored token for this email
    const tokenRef = this.firebaseService.firestore
      .collection('password_reset_tokens')
      .doc(email);

    const tokenDoc = await tokenRef.get();

    if (!tokenDoc.exists) {
      throw new BadRequestException(
        'Invalid or expired password reset token.',
      );
    }

    const data = tokenDoc.data()!;

    // Step 2b — constant-time compare of hashes
    if (
      !crypto.timingSafeEqual(
        Buffer.from(hashedToken, 'hex'),
        Buffer.from(data.hashedToken, 'hex'),
      )
    ) {
      throw new BadRequestException(
        'Invalid or expired password reset token.',
      );
    }

    // Step 3 — check expiry
    if (new Date() > new Date(data.expiresAt)) {
      await tokenRef.delete(); // clean up expired token
      throw new BadRequestException('Password reset token has expired.');
    }

    // Step 4 — update Firebase Auth password
    try {
      const user = await this.firebaseService.auth.getUserByEmail(email);
      await this.firebaseService.auth.updateUser(user.uid, {
        password: newPassword,
      });
      this.logger.log(`Password successfully reset for ${email}`);
    } catch (error: any) {
      this.logger.error(
        `Failed to update password for ${email}`,
        error.stack,
      );
      throw new InternalServerErrorException(
        'Could not update password. Please try again.',
      );
    }

    // Step 5 — delete consumed token
    await tokenRef.delete();
    this.logger.log(`Reset token consumed and deleted for ${email}`);
  }
}
