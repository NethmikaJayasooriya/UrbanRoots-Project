const nodemailer = require('nodemailer');

async function test() {
  const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: {
      user: 'nethmidivakara@gmail.com',
      pass: 'bjvwvzccazgmlvup'
    },
    tls: {
      rejectUnauthorized: false
    }
  });

  try {
    const info = await transporter.sendMail({
      from: '"UrbanRoots" <nethmidivakara@gmail.com>',
      to: 'nethmidivakara@gmail.com', // send to self
      subject: 'Test Email',
      text: 'This is a test to debug SMTP issues'
    });
    console.log('Success:', info);
  } catch (err) {
    console.error('Error sending email:', err);
  }
}

test();
