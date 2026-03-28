const axios = require('axios');
const crypto = require('crypto');
const dotenv = require('dotenv');

dotenv.config();

async function run() {
  const merchantId = process.env.PAYHERE_MERCHANT_ID || '1234567';
  const secret = process.env.PAYHERE_SECRET || 'xyz123';
  const orderId = 'TEST-ORD-' + Date.now();
  const amount = '150.00';
  const currency = 'LKR';
  const statusCode = '2'; // Success

  console.log('--- PayHere Notification Simulation ---');
  console.log('OrderID:', orderId);
  
  // Hashing logic from MarketplaceService
  const hashedSecret = crypto.createHash('md5').update(secret).digest('hex').toUpperCase();
  const expectedHash = crypto.createHash('md5')
    .update(merchantId + orderId + amount + currency + statusCode + hashedSecret)
    .digest('hex')
    .toUpperCase();

  const payload = {
    merchant_id: merchantId,
    order_id: orderId,
    payhere_amount: amount,
    payhere_currency: currency,
    status_code: statusCode,
    md5sig: expectedHash,
  };

  console.log('Generated Signature:', expectedHash);

  try {
    // 1. Post to the local backend
    console.log('Sending notification to backend...');
    const response = await axios.post('http://localhost:3000/marketplace/payhere/notify', payload);
    console.log('Backend response:', response.data);
    
    if (response.data === 'ORDER_NOT_FOUND' || response.data === 'OK') {
      console.log('\nVerification SUCCESS: Hash verification passed in the backend.');
      console.log('Note: "ORDER_NOT_FOUND" is expected if you haven\'t manually created the order in the DB first.');
    } else {
      console.error('\nVerification FAILED: Backend returned', response.data);
    }
  } catch (err) {
    if (err.response) {
      console.error('\nVerification FAILED: Backend returned error', err.response.status, err.response.data);
    } else {
      console.error('\nVerification FAILED:', err.message);
    }
  }
}

run();
