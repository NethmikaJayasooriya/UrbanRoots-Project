/**
 * Firebase Cloud Functions — Firestore → Supabase Sync Triggers
 *
 * Listens for writes to the Firestore `users/{uid}` collection and
 * upserts the data into the Supabase PostgreSQL `users` table.
 */

import { setGlobalOptions } from 'firebase-functions/v2';
import {
  onDocumentWritten,
  FirestoreEvent,
  Change,
  DocumentSnapshot,
} from 'firebase-functions/v2/firestore';
import * as logger from 'firebase-functions/logger';
import { getSupabaseClient } from './supabase-client';

// Global options for all functions
setGlobalOptions({ maxInstances: 10 });

// ─── Helper: map Firestore camelCase fields → Supabase snake_case ───

interface SupabaseUserRow {
  uid: string;
  email?: string | null;
  first_name?: string | null;
  last_name?: string | null;
  phone?: string | null;
  auth_provider?: string | null;
  profile_pic_url?: string | null;
  is_onboarded?: boolean;
  is_seller?: boolean;
  synced_at: string;
  created_at?: string | null;
  updated_at?: string | null;
}

function mapFirestoreUserToSupabase(
  uid: string,
  data: Record<string, any>,
): SupabaseUserRow {
  return {
    uid,
    email: data.email ?? null,
    first_name: data.firstName ?? data.first_name ?? null,
    last_name: data.lastName ?? data.last_name ?? null,
    phone: data.phone ?? data.phone_number ?? null,
    auth_provider: data.authProvider ?? data.auth_provider ?? 'email/password',
    profile_pic_url:
      data.profilePic ??
      data.profile_pic ??
      data.profile_pic_url ??
      data.avatar_url ??
      null,
    is_onboarded: data.is_onboarded ?? data.isOnboarded ?? false,
    is_seller: data.is_seller ?? data.isSeller ?? false,
    synced_at: new Date().toISOString(),
    created_at: toISOOrNull(data.createdAt ?? data.created_at),
    updated_at: toISOOrNull(data.updatedAt ?? data.updated_at),
  };
}

function toISOOrNull(value: any): string | null {
  if (!value) return null;
  // Firestore Timestamp objects have a toDate() method
  if (typeof value?.toDate === 'function') {
    return value.toDate().toISOString();
  }
  if (value instanceof Date) {
    return value.toISOString();
  }
  if (typeof value === 'string') {
    return value;
  }
  return null;
}

// ─── Cloud Function: onUserWrite ────────────────────────────────

/**
 * Triggered whenever a document in `users/{uid}` is created or updated.
 * Deletes from Supabase are handled when the Firestore doc is deleted.
 */
export const onUserWrite = onDocumentWritten(
  'users/{uid}',
  async (
    event: FirestoreEvent<
      Change<DocumentSnapshot> | undefined,
      { uid: string }
    >,
  ) => {
    const uid = event.params.uid;

    // If data was deleted from Firestore
    if (!event.data?.after?.exists) {
      logger.info(`User ${uid} deleted from Firestore — removing from Supabase`);
      try {
        const supabase = getSupabaseClient();
        const { error } = await supabase
          .from('users')
          .delete()
          .eq('uid', uid);

        if (error) {
          logger.error(`Failed to delete user ${uid} from Supabase`, error);
        } else {
          logger.info(`User ${uid} removed from Supabase`);
        }
      } catch (err) {
        logger.error(`Error deleting user ${uid} from Supabase`, err);
      }
      return;
    }

    // Document was created or updated
    const afterData = event.data.after.data();
    if (!afterData) {
      logger.warn(`No data found in after snapshot for user ${uid}`);
      return;
    }

    const row = mapFirestoreUserToSupabase(uid, afterData);

    try {
      const supabase = getSupabaseClient();
      const { error } = await supabase
        .from('users')
        .upsert([row], { onConflict: 'uid' });

      if (error) {
        logger.error(
          `Failed to upsert user ${uid} to Supabase: ${error.message}`,
          error,
        );
      } else {
        logger.info(`User ${uid} synced to Supabase successfully`);
      }
    } catch (err) {
      logger.error(`Error syncing user ${uid} to Supabase`, err);
    }
  },
);
