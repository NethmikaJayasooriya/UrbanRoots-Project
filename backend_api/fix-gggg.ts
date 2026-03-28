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

  // Link any product with invalid/null seller_id to the official shop
  // HimasaraShop ID: c39a094c-4b5a-47df-96f6-aaed146e2e6f
  const res = await client.query(`
    UPDATE products 
    SET seller_id = 'c39a094c-4b5a-47df-96f6-aaed146e2e6f'
    WHERE seller_id IS NULL OR seller_id = 'ffffffff-ffff-ffff-ffff-ffffffffffff'
    RETURNING name;
  `);

  console.log(`Updated ${res.rowCount} products!`);
  res.rows.forEach(p => console.log(`Linked: ${p.name}`));

  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
