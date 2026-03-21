import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Allow Flutter (web/emulator/device) to reach the API
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    allowedHeaders: 'Content-Type, Accept, Authorization',
  });

  // Auto-validate all incoming DTOs
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,       // strip unknown fields
      forbidNonWhitelisted: false,
      transform: true,       // auto-cast types (string → number etc.)
    }),
  );

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`UrbanRoots API running on http://localhost:${port}`);
}

bootstrap();
