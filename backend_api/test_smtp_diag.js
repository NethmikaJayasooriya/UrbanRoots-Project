const nodemailer = require('nodemailer');
require('dotenv').config();

async function test() {
  console.log('Testing SMTP with:');
  console.log('Host:', process.env.SMTP_HOST);
  console.log('Port:', process.env.SMTP_PORT);
  console.log('User:', process.env.SMTP_USER);
  
  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT),
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
    tls: {
      rejectUnauthorized: false
    }
  });

  try {
    console.log('Verifying connection...');
    await transporter.verify();
    console.log('Connection successful!');

    console.log('Sending test mail to:', process.env.SMTP_USER);
    const info = await transporter.sendMail({
      from: `"UrbanRoots Test" <${process.env.SMTP_USER}>`,
      to: process.env.SMTP_USER,
      subject: 'UrbanRoots SMTP Diagnostic',
      text: 'If you see this, your SMTP settings are working perfectly.'
    });
    console.log('Message sent: %s', info.messageId);
  } catch (error) {
    console.error('SMTP Error:', error);
  }
}

test();
