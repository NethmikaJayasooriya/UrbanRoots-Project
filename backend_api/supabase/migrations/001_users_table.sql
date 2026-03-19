-- ============================================================
-- Supabase Migration: Users table
-- Stores user profile data synced from Firebase/Firestore
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
  uid              TEXT PRIMARY KEY,                       -- Firebase UID
  email            TEXT UNIQUE NOT NULL,
  first_name       TEXT,
  last_name        TEXT,
  phone            TEXT,
  auth_provider    TEXT DEFAULT 'email/password',
  profile_pic_url  TEXT,
  is_onboarded     BOOLEAN DEFAULT FALSE,
  is_seller        BOOLEAN DEFAULT FALSE,
  password_hash    TEXT,                                   -- bcrypt hash (local auth)
  synced_at        TIMESTAMPTZ,                            -- last Firestore → Supabase sync
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

-- Index for email lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- Index for auth provider queries
CREATE INDEX IF NOT EXISTS idx_users_auth_provider ON users (auth_provider);
