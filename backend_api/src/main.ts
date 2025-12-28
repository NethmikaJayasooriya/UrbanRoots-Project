import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // This line is the KEY FIX:
  app.enableCors();

  await app.listen(3000);
}
bootstrap();