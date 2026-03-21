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

const initialProducts = [
  { id: '11111111-1111-1111-1111-111111111111', name: 'Tomato Seeds', category: 'Seeds', price: 250.0, description: 'High-yield tomato seeds suitable for urban gardens.', imageUrl: 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'spa_rounded' },
  { id: '22222222-2222-2222-2222-222222222222', name: 'Organic Fertilizer', category: 'Fertilizers', price: 900.0, description: '100% organic compost fertilizer, 2kg bag.', imageUrl: 'https://images.unsplash.com/photo-1599839619722-39751411ea63?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'eco_rounded' },
  { id: '33333333-3333-3333-3333-333333333333', name: 'Indoor Fern', category: 'Indoor', price: 1200.0, description: 'Low-maintenance indoor fern for better air quality.', imageUrl: 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'local_florist_rounded' },
  { id: '44444444-4444-4444-4444-444444444444', name: 'Gardening Gloves', category: 'Tools', price: 450.0, description: 'Durable, weather-resistant gardening gloves.', imageUrl: 'https://images.unsplash.com/photo-1416879598056-0cbb04922b0a?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'hardware_rounded' },
  { id: '55555555-5555-5555-5555-555555555555', name: 'Watering Can', category: 'Tools', price: 850.0, description: 'Ergonomic 2L watering can with a detachable spout.', imageUrl: 'https://images.unsplash.com/photo-1585072044322-9599d1461164?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'hardware_rounded' },
  { id: '66666666-6666-6666-6666-666666666666', name: 'Basil Plant', category: 'Plants', price: 350.0, description: 'Fresh basil plant, perfect for your kitchen window.', imageUrl: 'https://images.unsplash.com/photo-1608681290619-a1d2f00f0aa0?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'local_florist_rounded' },
  { id: '77777777-7777-7777-7777-777777777777', name: 'Chili Seeds', category: 'Seeds', price: 150.0, description: 'Spicy Kochchi chili seeds.', imageUrl: 'https://images.unsplash.com/photo-1588015383566-1caba908be59?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'spa_rounded' },
  { id: '88888888-8888-8888-8888-888888888888', name: 'Neem Oil (Pesticide)', category: 'Care', price: 650.0, description: 'Natural pest control for organic farming.', imageUrl: 'https://images.unsplash.com/photo-1611078712165-4f5195e87aed?q=80&w=800&auto=format&fit=crop', placeholderIcon: 'spa_rounded' },
];

async function run() {
  await client.connect();

  try {
    await client.query('ALTER TABLE "product" ADD COLUMN "imageUrl" varchar');
    console.log('Added imageUrl column manually.');
  } catch (e) {
    console.log('Skip adding imageUrl:', e.message);
  }

  for (const p of initialProducts) {
    try {
      await client.query(
        'INSERT INTO "product" (id, name, category, price, description, "imageUrl", "placeholderIcon") VALUES ($1, $2, $3, $4, $5, $6, $7)',
        [p.id, p.name, p.category, p.price, p.description, p.imageUrl, p.placeholderIcon]
      );
    } catch (e) { console.log('Error adding', p.name, e.message); }
  }
  console.log('Seeded completely!');
  await client.end();
}

run();
