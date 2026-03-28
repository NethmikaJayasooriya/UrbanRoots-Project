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
  
  const res = await client.query('SELECT * FROM orders ORDER BY "createdAt" DESC LIMIT 3;');
  
  console.log("=== LATEST 3 ORDERS ===");
  res.rows.forEach(r => {
    console.log(`OrderID: ${r.orderId}`);
    console.log(`UserID: ${r.userId === null ? 'NULL' : r.userId}`);
    console.log(`Payment: ${r.paymentMethod}`);
    console.log(`Created: ${r.createdAt}`);
    console.log('---');
  });

  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
