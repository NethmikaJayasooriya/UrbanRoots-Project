const { Client } = require('pg');
require('dotenv').config();

const client = new Client({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: { rejectUnauthorized: false }
});

async function run() {
  await client.connect();
  console.log('Connected to PostgreSQL Supabase database.');
  
  try {
    // Delete all products to trigger the NodeJS seeder with image URLs
    await client.query('DELETE FROM "product"'); 
    console.log('Successfully wiped old products! Restarting backend will now load photo URLs.');
  } catch (e) {
    console.error('Error clearing products:', e);
  } finally {
    await client.end();
  }
}

run();
