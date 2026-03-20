import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { defineString } from 'firebase-functions/params';

// Firebase Functions environment params (set via `firebase functions:config:set`
// or through .env / .env.local in the functions directory)
const supabaseUrl = defineString('SUPABASE_URL');
const supabaseServiceRoleKey = defineString('SUPABASE_SERVICE_ROLE_KEY');

let client: SupabaseClient | null = null;

/**
 * Returns a singleton Supabase client configured with the service-role key.
 * The service-role key bypasses Row Level Security, which is required
 * for server-side upserts from Cloud Functions.
 */
export function getSupabaseClient(): SupabaseClient {
  if (!client) {
    const url = supabaseUrl.value();
    const key = supabaseServiceRoleKey.value();

    if (!url || !key) {
      throw new Error(
        'Missing Supabase credentials. Set SUPABASE_URL and ' +
          'SUPABASE_SERVICE_ROLE_KEY in the functions environment.',
      );
    }

    client = createClient(url, key, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });
  }

  return client;
}
