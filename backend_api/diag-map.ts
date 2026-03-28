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

  const productsRes = await client.query('SELECT name, seller_id FROM products;');
  console.log("Products and their Seller IDs:");
  productsRes.rows.forEach(p => {
    console.log(`Product: ${p.name}, SellerID: ${p.seller_id}`);
  });

  const sellersRes = await client.query('SELECT id, brand_name FROM sellers;');
  console.log("\nSellers and their IDs:");
  sellersRes.rows.forEach(s => {
    console.log(`Seller: ${s.brand_name}, ID: ${s.id}`);
  });

  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
