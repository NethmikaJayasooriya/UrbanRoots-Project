const { Client } = require('pg');
require('dotenv').config();

async function patchSchema() {
  const client = new Client({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME,
    user: process.env.DB_USERNAME || process.env.DB_USER,
    password: process.env.DB_PASSWORD || process.env.DB_PASS,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log("Connected to DB!");

    // 1. App Reviews Patch
    try {
      await client.query(`ALTER TABLE app_reviews DROP CONSTRAINT IF EXISTS app_reviews_user_id_fkey;`);
      await client.query(`ALTER TABLE app_reviews ALTER COLUMN user_id TYPE text;`);
      console.log("Successfully patched app_reviews user_id to text!");
    } catch (e) {
      console.log("app_reviews patch failed:", e.message);
    }

    // 2. Streaks Patch
    try {
      await client.query(`ALTER TABLE streaks DROP CONSTRAINT IF EXISTS streaks_user_id_fkey;`);
      await client.query(`ALTER TABLE streaks ALTER COLUMN user_id TYPE text;`);
      console.log("Successfully patched streaks user_id to text!");
    } catch (e) {
      console.log("streaks patch failed:", e.message);
    }

  } catch (e) {
    console.error("Connection failed:", e.message);
  } finally {
    await client.end();
  }
}

patchSchema();
