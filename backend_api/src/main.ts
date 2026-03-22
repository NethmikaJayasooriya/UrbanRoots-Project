import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // serve static upload dirs
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',
  });

  // cors config
  app.enableCors({
    origin: '*', // TODO: lock down origin before prod
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
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
  const port = process.env.PORT ?? 3000;
  await app.listen(port, '0.0.0.0');

  console.log('--------------------------------------------------');
  console.log(`🚀 UrbanRoots API is running on: http://localhost:${port}`);
  console.log('--------------------------------------------------');
}

bootstrap();