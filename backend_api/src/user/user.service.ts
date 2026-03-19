import { Injectable, InternalServerErrorException, Logger, NotFoundException } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';
import { DataSource } from 'typeorm';

export interface UserProfileData {
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  authProvider?: string;
  profilePic?: string;
  is_onboarded?: boolean;
  is_seller?: boolean;
}

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);

  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly dataSource: DataSource,
  ) {}

  private get userTableName(): string {
    const tableName = process.env.PG_USER_TABLE ?? 'users';
    if (!/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(tableName)) {
      throw new InternalServerErrorException('Invalid PG_USER_TABLE name.');
    }
    return tableName;
  }

  private normalizeValue(value?: string | boolean): string | boolean | undefined {
    if (typeof value === 'string') {
      const trimmed = value.trim();
      return trimmed.length > 0 ? trimmed : undefined;
    }
    return value;
  }

  private async getUserTableColumns(tableName: string): Promise<Set<string>> {
    const rows = await this.dataSource.query(
      `
      SELECT column_name
      FROM information_schema.columns
      WHERE table_schema = current_schema()
        AND table_name = $1
    `,
      [tableName],
    );

    return new Set<string>(rows.map((row: { column_name: string }) => row.column_name));
  }

  private pickFirstExistingColumn(columns: Set<string>, candidates: string[]): string | undefined {
    return candidates.find((name) => columns.has(name));
  }

  private quoteIdentifier(identifier: string): string {
    return `"${identifier.replace(/"/g, '""')}"`;
  }

  private async syncProfileToPostgres(uid: string, profileData: UserProfileData): Promise<void> {
    const tableName = this.userTableName;
    const columns = await this.getUserTableColumns(tableName);

    if (columns.size === 0) {
      throw new InternalServerErrorException(
        `PostgreSQL table '${tableName}' was not found in current schema.`,
      );
    }

    const uidColumn = this.pickFirstExistingColumn(columns, [
      'uid',
      'firebase_uid',
      'firebaseUid',
      'user_uid',
      'userUid',
    ]);

    if (!uidColumn) {
      throw new InternalServerErrorException(
        `Table '${tableName}' must include one UID column (uid/firebase_uid/firebaseUid/user_uid/userUid).`,
      );
    }

    const now = new Date();
    const valueByColumn = new Map<string, unknown>();

    const setIfColumnExists = (candidateColumns: string[], value: unknown) => {
      const col = this.pickFirstExistingColumn(columns, candidateColumns);
      if (col && value !== undefined) {
        valueByColumn.set(col, value);
      }
    };

    valueByColumn.set(uidColumn, uid);

    setIfColumnExists(['first_name', 'firstName'], this.normalizeValue(profileData.firstName));
    setIfColumnExists(['last_name', 'lastName'], this.normalizeValue(profileData.lastName));
    setIfColumnExists(['email'], this.normalizeValue(profileData.email));
    setIfColumnExists(['phone', 'phone_number', 'phoneNumber'], this.normalizeValue(profileData.phone));
    setIfColumnExists(['auth_provider', 'authProvider', 'provider'], this.normalizeValue(profileData.authProvider));
    setIfColumnExists(
      ['profile_pic', 'profile_pic_url', 'profilePic', 'profile_image_url', 'avatar_url', 'image_url'],
      this.normalizeValue(profileData.profilePic),
    );
    setIfColumnExists(['is_onboarded', 'isOnboarded'], profileData.is_onboarded);
    setIfColumnExists(['is_seller', 'isSeller'], profileData.is_seller);
    setIfColumnExists(['updated_at', 'updatedAt'], now);

    const existingRows = await this.dataSource.query(
      `SELECT 1 FROM ${this.quoteIdentifier(tableName)} WHERE ${this.quoteIdentifier(uidColumn)} = $1 LIMIT 1`,
      [uid],
    );

    if (existingRows.length > 0) {
      const updateEntries = [...valueByColumn.entries()].filter(([column]) => column !== uidColumn);
      if (updateEntries.length === 0) {
        return;
      }

      const setClause = updateEntries
        .map(([column], index) => `${this.quoteIdentifier(column)} = $${index + 2}`)
        .join(', ');
      const params = [uid, ...updateEntries.map(([, value]) => value)];

      await this.dataSource.query(
        `UPDATE ${this.quoteIdentifier(tableName)} SET ${setClause} WHERE ${this.quoteIdentifier(uidColumn)} = $1`,
        params,
      );
      return;
    }

    setIfColumnExists(['created_at', 'createdAt'], now);

    const insertEntries = [...valueByColumn.entries()];
    const insertColumns = insertEntries.map(([column]) => this.quoteIdentifier(column)).join(', ');
    const placeholders = insertEntries.map((_, index) => `$${index + 1}`).join(', ');
    const insertValues = insertEntries.map(([, value]) => value);

    await this.dataSource.query(
      `INSERT INTO ${this.quoteIdentifier(tableName)} (${insertColumns}) VALUES (${placeholders})`,
      insertValues,
    );
  }

  /**
   * Updates an existing user's profile in Firestore and PostgreSQL
   * (used for setup profile and edit profile).
   * Makes PostgreSQL sync non-blocking - will log errors but not fail the request.
   */
  async updateProfile(uid: string, profileData: UserProfileData): Promise<void> {
    try {
      // Attempt PostgreSQL sync in the background (non-blocking)
      this.syncProfileToPostgres(uid, profileData).catch((postgresError) => {
        this.logger.warn(`PostgreSQL sync failed for user ${uid}, but Firestore update succeeded. Error: ${postgresError.message}`);
      });

      // Update Firestore - this is the primary data source
      const userRef = this.firebaseService.firestore.collection('users').doc(uid);
      
      // Fetch existing to see if we need to set createdAt
      const doc = await userRef.get();
      const updatePayload: any = {
        ...profileData,
        updatedAt: new Date(),
      };
      
      // Clean undefined properties to prevent Firebase Admin SDK errors
      Object.keys(updatePayload).forEach(key => {
        if (updatePayload[key] === undefined) {
          delete updatePayload[key];
        }
      });
      
      if (!doc.exists || !doc.data()?.createdAt) {
        updatePayload.createdAt = new Date();
      }

      await userRef.set(updatePayload, { merge: true });
      
      this.logger.log(`Profile updated for user: ${uid} in Firestore`);
    } catch (error) {
      this.logger.error(`Failed to update profile for user ${uid}`, error.stack);
      throw new InternalServerErrorException('Failed to update user profile. Please try again.');
    }
  }

  /**
   * Fetches the user profile from Firestore.
   */
  async getProfile(uid: string) {
    try {
      const doc = await this.firebaseService.firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw new NotFoundException('User profile not found');
      }
      return doc.data();
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      this.logger.error(`Failed to fetch profile for user ${uid}`, error.stack);
      throw new InternalServerErrorException('Failed to fetch user profile.');
    }
  }
}
