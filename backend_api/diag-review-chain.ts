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

  // 1. Get Seller
  const sellerRes = await client.query("SELECT id, brand_name, rating FROM sellers WHERE brand_name LIKE '%Himasara%';");
  const seller = sellerRes.rows[0];
  if (!seller) {
    console.log("Seller not found");
    await client.end();
    return;
  }
  console.log(`Seller: ${seller.brand_name} (ID: ${seller.id}, Rating: ${seller.rating})`);

  // 2. Get Products
  const productsRes = await client.query("SELECT id, name FROM products WHERE seller_id = $1;", [seller.id]);
  console.log(`Products Found: ${productsRes.rowCount}`);
  productsRes.rows.forEach(p => console.log(` - Product: ${p.name} (ID: ${p.id})`));

  if (productsRes.rowCount > 0) {
    const productIds = productsRes.rows.map(p => p.id);
    // 3. Get Reviews
    const reviewsRes = await client.query("SELECT id, \"productId\", rating FROM reviews WHERE \"productId\" = ANY($1);", [productIds]);
    console.log(`Reviews Found: ${reviewsRes.rowCount}`);
    reviewsRes.rows.forEach(r => console.log(` - Review ID: ${r.id}, Product: ${r.productId}, Rating: ${r.rating}`));
    
    if (reviewsRes.rowCount > 0) {
      const avg = reviewsRes.rows.reduce((s, r) => s + r.rating, 0) / reviewsRes.rowCount;
      console.log(`Calculated Average: ${avg}`);
    }
  }

  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
