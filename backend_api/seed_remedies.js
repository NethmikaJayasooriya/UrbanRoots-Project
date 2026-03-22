const fs = require('fs');
const { Client } = require('pg');
require('dotenv').config({ path: './.env' });

async function seed() {
  const dartCode = fs.readFileSync('../mobile_app/lib/disease_detail_screen.dart', 'utf8');

  // Regex to match: RemedyInfo(name: '...', type: '...', description: '...', frequency: '...')
  const regex = /RemedyInfo\(name:\s*'([^']+)',\s*type:\s*'([^']+)',\s*description:\s*'([^']+)'/g;
  
  const remedies = new Map();
  let match;
  while ((match = regex.exec(dartCode)) !== null) {
    const name = match[1];
    const type = match[2];
    const desc = match[3];
    if (!remedies.has(name)) {
      remedies.set(name, { name, type, desc });
    }
  }

  console.log(`Found ${remedies.size} unique remedies.`);

  const client = new Client({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME,
    user: process.env.DB_USERNAME || process.env.DB_USER,
    password: process.env.DB_PASSWORD || process.env.DB_PASS,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log("Connected to Postgres!");
    
    // We will assign a random seller uuid so they appear as legitimate listings.
    // Wait, the products table is 'products' not 'marketplace_products'
    const sellerId = '11111111-1111-1111-1111-111111111111';

    let inserted = 0;
    for (const r of remedies.values()) {
      // Check if product exists
      const res = await client.query('SELECT id FROM products WHERE name = $1', [r.name]);
      if (res.rowCount === 0) {
        // Random price between 10 and 50
        const price = Math.floor(Math.random() * 4000 + 1000) / 100; 

        await client.query(`
          INSERT INTO products (name, category, description, price, image_url, placeholder_icon, is_active, seller_id)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        `, [
          r.name, 
          'treatment', 
          r.desc, 
          price, 
          null, // image_url (we can fallback to placeholder)
          r.type === 'Organic' ? 'eco_rounded' : 'science_rounded', 
          true,
          null
        ]);
        inserted++;
      }
    }
    console.log(`Inserted ${inserted} new remedies as marketplace products!`);
  } catch(e) {
    console.error("DB Error:", e);
  } finally {
    await client.end();
  }
}

seed();
