import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // 1. Enable CORS for Flutter & IoT Devices
  // This allows your Flutter app (Web/Emulator) and ESP32 to talk to this API
  app.enableCors({
    origin: '*', // For development; change to specific domain in production
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    allowedHeaders: 'Content-Type, Accept, Authorization',
    credentials: true,
  });

  // 2. Global Validation
  // This ensures data coming from your ESP32 or Flutter app is clean
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,       // Automatically removes any properties not in the DTO
      forbidNonWhitelisted: false,
      transform: true,       // Automatically converts strings to numbers/booleans where needed
    }),
  );

  // 3. Start the Server
  const port = process.env.PORT ?? 3000;
  await app.listen(port);

  console.log('--------------------------------------------------');
  console.log(`🚀 UrbanRoots API is running on: http://localhost:${port}`);
  console.log(`📊 Swagger/Docs available (if installed): http://localhost:${port}/api`);
  console.log('--------------------------------------------------');
}

bootstrap();