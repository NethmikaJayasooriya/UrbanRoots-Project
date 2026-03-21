import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

<<<<<<< HEAD
// Root App
import { AppController } from './app.controller';
import { AppService } from './app.service';

// Garden & Weather Features
import { GardenModule } from './garden/garden.module';
import { WeatherModule } from './weather/weather.module';
import { DiseaseModule } from './disease/disease.module';

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
    GardenModule,
    WeatherModule,
    AuthModule,
    FirebaseModule,
    OtpModule,
    UserModule,
    PasswordModule,
    DiseaseModule,
=======
// Existing Apps
import { AppController } from './app.controller';
import { AppService } from './app.service';

// Feature Modules
import { MarketplaceModule } from './marketplace/marketplace.module';
import { SupabaseModule } from './common/supabase/supabase.module';
import { ProfileModule } from './profile/profile.module';
import { NotificationsModule } from './notifications/notifications.module';
import { ReviewsModule } from './reviews/reviews.module';
import { TermsModule } from './terms/terms.module';
import { SupportModule } from './support/support.module';
import { SellerModule } from './seller/seller.module';
import { PreferencesModule } from './preferences/preferences.module';
import { SubscriptionsModule } from './subscriptions/subscriptions.module';
import { ProductsModule } from './products/products.module';
import { SalesModule } from './sales/sales.module';
import { SellersModule } from './sellers/sellers.module';
import { BeneficiariesModule } from './beneficiaries/beneficiaries.module';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    // ── Env Configuration ──────────────────────────────────
    ConfigModule.forRoot({ isGlobal: true }),

    // ── Database (Supabase / Postgres) ─────────────────────
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        type: 'postgres',
        host: cfg.get<string>('DB_HOST'),
        port: cfg.get<number>('DB_PORT') || 5432,
        username: cfg.get<string>('DB_USER') || cfg.get<string>('DB_USERNAME'),
        password: cfg.get<string>('DB_PASS') || cfg.get<string>('DB_PASSWORD'),
        database: cfg.get<string>('DB_NAME'),
        // SSL is usually required for Supabase remote connections
        ssl: { rejectUnauthorized: false },
        autoLoadEntities: true,
        // Set to false if your tables are already managed in Supabase dashboard
        synchronize: false,
      }),
    }),

    // ── Feature Modules ────────────────────────────────────
    UsersModule,
    SellersModule,
    ProductsModule,
    SalesModule,
    BeneficiariesModule,
    MarketplaceModule,
    SupabaseModule,
    ProfileModule,
    NotificationsModule,
    ReviewsModule,
    TermsModule,
    SupportModule,
    SellerModule,
    PreferencesModule,
    SubscriptionsModule,
>>>>>>> origin/feature/marketplace
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }