const { Client } = require('pg');
require('dotenv').config();

async function run() {
  const client = new Client({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: { rejectUnauthorized: false }
  });

  await client.connect();
  console.log("USERS:");
  const users = await client.query('SELECT uid, email, auth_provider FROM users');
  console.table(users.rows);

  console.log("\nGARDENS:");
  const gardens = await client.query('SELECT garden_id, user_id, garden_name FROM gardens');
  console.table(gardens.rows);

  await client.end();
}

run().catch(console.error);
