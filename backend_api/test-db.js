const { Client } = require('pg');
require('dotenv').config();

const client = new Client({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USERNAME || process.env.DB_USER,
  password: process.env.DB_PASSWORD || process.env.DB_PASS,
  database: process.env.DB_NAME,
  ssl: { rejectUnauthorized: false }
});

async function run() {
  await client.connect();
  const res = await client.query("SELECT uid, profile_pic FROM users WHERE uid = 'jesOsWg91fYU1qnAyyKlRKzy7sh1';");
  console.log('Postgres:', JSON.stringify(res.rows, null, 2));
  await client.end();
}
run().catch(console.error);
