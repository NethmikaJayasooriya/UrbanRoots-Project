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

  const res = await client.query('SELECT name, seller_id, is_active FROM products;');
  console.log("All Products Status:");
  res.rows.forEach(p => {
    console.log(`Product: ${p.name}, SellerID: ${p.seller_id}, IsActive: ${p.is_active} (${typeof p.is_active})`);
  });

  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
