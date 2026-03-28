import { Client } from 'pg';
import * as fs from 'fs';

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
  
  try {
    const res = await client.query('ALTER TABLE orders ALTER COLUMN "userId" TYPE character varying(255);');
    console.log("Successfully altered column type!", res);
  } catch(e) {
    console.error("ALTER ERROR: ", e);
  }

  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
