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

  // 1. Get all sellers
  const sellersRes = await client.query('SELECT id, uid, brand_name, rating FROM sellers;');
  console.log("Sellers Count:", sellersRes.rows.length);
  for (const seller of sellersRes.rows) {
      console.log(`Seller: ${seller.brand_name} (ID: ${seller.id}, UID: ${seller.uid}, Rating: ${seller.rating})`);
      
      // Get products for this seller
      const productsRes = await client.query('SELECT id, name FROM products WHERE seller_id = $1;', [seller.id]);
      console.log(`  Products Count: ${productsRes.rows.length}`);
      
      if (productsRes.rows.length > 0) {
          const productIds = productsRes.rows.map(p => p.id);
          // Get reviews for these products
          const reviewsRes = await client.query('SELECT id, rating FROM reviews WHERE "productId" = ANY($1::uuid[]);', [productIds]);
          console.log(`    Reviews Count: ${reviewsRes.rows.length}`);
          if (reviewsRes.rows.length > 0) {
              const avg = reviewsRes.rows.reduce((sum, r) => sum + r.rating, 0) / reviewsRes.rows.length;
              console.log(`    Calculated Average: ${avg}`);
          }
      }
  }

  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
