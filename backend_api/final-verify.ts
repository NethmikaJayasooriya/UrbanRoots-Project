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

  // This script simulates what happens when the app calls the backend
  // Seller: HimasaraShop (ID: c39a094c-4b5a-47df-96f6-aaed146e2e6f)
  const sellerId = 'c39a094c-4b5a-47df-96f6-aaed146e2e6f';

  // 1. Manually calculate the real average for verification
  const products = await client.query("SELECT id FROM products WHERE seller_id = $1;", [sellerId]);
  const pIds = products.rows.map(p => p.id);
  const reviews = await client.query("SELECT rating FROM reviews WHERE \"productId\" = ANY($1);", [pIds]);
  
  if (reviews.rowCount > 0) {
    const avg = reviews.rows.reduce((s, r) => s + r.rating, 0) / reviews.rowCount;
    const finalAvg = parseFloat(avg.toFixed(2));
    
    console.log(`Real Calculated Average: ${finalAvg}`);

    // 2. Perform the update (simulating MarketplaceService.updateSellerRating)
    await client.query("UPDATE sellers SET rating = $1 WHERE id = $2;", [finalAvg, sellerId]);
    console.log("Database rating column updated!");

    // 3. Final check
    const final = await client.query("SELECT rating FROM sellers WHERE id = $1;", [sellerId]);
    console.log(`Final Rating in Database: ${final.rows[0].rating}`);
  } else {
    console.log("No reviews found to calculate rating.");
  }

  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
