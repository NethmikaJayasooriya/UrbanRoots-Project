import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Serve static UI assets (product uploads)
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',
  });

  // 1. Enable CORS for Flutter & IoT Devices
  app.enableCors({
    origin: '*', // For development; change to specific domain in production
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    allowedHeaders: 'Content-Type, Accept, Authorization, x-user-id',
    credentials: true,
  });

  // 2. Global Validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false,
      transform: true,
    }),
  );

  // 3. Start the Server
  const port = process.env.PORT ?? 3000;
  await app.listen(port, '0.0.0.0');

  console.log('--------------------------------------------------');
  console.log(`🚀 UrbanRoots API is running on: http://localhost:${port}`);
  console.log('--------------------------------------------------');
}

bootstrap();