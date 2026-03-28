import { Client } from 'pg';

const client = new Client({
  host: process.env.DB_HOST || 'aws-1-ap-southeast-1.pooler.supabase.com',
  port: 5432,
  user: process.env.DB_USERNAME || 'postgres.lbdyfmhetidvimwawvmi',
  password: process.env.DB_PASSWORD || 'UrbanRoots(2025)',
  database: 'postgres',
  ssl: { rejectUnauthorized: false }
});

async function run() {
  await client.connect();
  console.log("Connected to DB!");

  const sellerId = 'c39a094c-4b5a-47df-96f6-aaed146e2e6f'; // HimasaraShop ID

  // Link all orphaned products to the one active seller
  const productsUpdate = await client.query('UPDATE products SET seller_id = $1 WHERE seller_id IS NULL;', [sellerId]);
  console.log(`Successfully linked ${productsUpdate.rowCount} orphaned products to seller ${sellerId}.`);

  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
