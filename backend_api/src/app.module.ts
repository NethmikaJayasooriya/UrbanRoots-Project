import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';

// Modules from your team member's folder structure
import { AuthModule } from './auth/auth.module';
import { FirebaseModule } from './firebase/firebase.module';
import { OtpModule } from './otp/otp.module';
import { UserModule } from './user/user.module';
import { SupabaseModule } from './supabase/supabase.module';
import { PasswordModule } from './password/password.module';

@Module({
  imports: [
    // 1. Loads the .env file globally
    ConfigModule.forRoot({ isGlobal: true }),

    // 2. Connects to Supabase using the .env variables
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
        autoLoadEntities: true,
        synchronize: true, // Auto-creates tables in Supabase based on entities
        ssl: {
          rejectUnauthorized: false, // REQUIRED for Supabase connections
        },
      }),
    }),

    // 3. Import existing feature modules
    AuthModule,
    FirebaseModule,
    OtpModule,
    UserModule,
    SupabaseModule,
    PasswordModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }