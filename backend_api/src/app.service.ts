import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return '🌱 UrbanRoots API is running!';
  }
}
