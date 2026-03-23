import * as dns from 'dns';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';


async function bootstrap() {
  // Force IPv4 DNS — Render blocks IPv6 outbound; smtp.gmail.com resolves
  // to IPv6 first on Node 17+, causing ENETUNREACH on SMTP connections.
  dns.setDefaultResultOrder('ipv4first');

  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // serve static upload dirs
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',
  });

  // cors config — wildcard + credentials is rejected by browsers; use explicit origin list
  app.enableCors({
    origin: (origin, callback) => {
      // allow requests with no origin (mobile apps, curl, Postman)
      if (!origin) return callback(null, true);
      const allowed = [
        'http://localhost:3000',
        'http://localhost:5000',  // flutter web default dev port
        'http://localhost:8080',  // flutter web alternate dev port
        'http://127.0.0.1:5000',
        'http://127.0.0.1:8080',
      ];
      if (allowed.includes(origin)) return callback(null, true);
      // allow any localhost port for local dev
      if (/^http:\/\/localhost:\d+$/.test(origin)) return callback(null, true);
      if (/^http:\/\/127\.0\.0\.1:\d+$/.test(origin)) return callback(null, true);
      callback(new Error(`CORS blocked: ${origin}`));
    },
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    allowedHeaders: 'Content-Type, Accept, Authorization, x-user-id',
    credentials: true,
  });

  // global validation pipes
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false,
      transform: true,
    }),
  );

  // boot server
  await app.listen(process.env.PORT || 3000, '0.0.0.0');

  console.log('--------------------------------------------------');
  console.log(`🚀 UrbanRoots API is running on: http://localhost:${process.env.PORT || 3000}`);
  console.log('--------------------------------------------------');
}

bootstrap();