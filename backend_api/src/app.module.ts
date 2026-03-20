import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

// Root App
import { AppController } from './app.controller';
import { AppService } from './app.service';

// Garden & Weather Features
import { GardensModule } from './gardens/gardens.module';
import { WeatherModule } from './weather/weather.module';

// Auth & User Profile Features
import { AuthModule } from './auth/auth.module';
import { FirebaseModule } from './firebase/firebase.module';
import { OtpModule } from './otp/otp.module';
import { PasswordModule } from './password/password.module';
import { UserModule } from './user/user.module';

@Module({
  imports: [
    // 1. Loads the .env file globally
    ConfigModule.forRoot({ isGlobal: true }),

    // 2. Connects to Supabase/Postgres using Async configuration
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get<string>('DB_HOST'),
        port: config.get<number>('DB_PORT'),
        username: config.get<string>('DB_USERNAME'),
        password: config.get<string>('DB_PASSWORD'),
        database: config.get<string>('DB_NAME'),
        autoLoadEntities: true, // This automatically loads 'User' and other entities
        synchronize: true, // Auto-creates tables in Supabase (Development only)
        ssl: {
          rejectUnauthorized: false, // Required for Supabase
        },
      }),
    }),

    // 3. Merged Feature Modules
    GardensModule,
    WeatherModule,
    AuthModule,
    FirebaseModule,
    OtpModule,
    UserModule,
    PasswordModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}