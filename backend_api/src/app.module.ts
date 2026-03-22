import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

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

// Marketplace Feature
import { MarketplaceModule } from './marketplace/marketplace.module';

// User Profile & Seller Hub Features (from feature/marketplace branch)
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
import { StreaksModule } from './streaks/streaks.module';

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
        port: config.get<number>('DB_PORT') || 5432,
        username: config.get<string>('DB_USERNAME') || config.get<string>('DB_USER'),
        password: config.get<string>('DB_PASSWORD') || config.get<string>('DB_PASS'),
        database: config.get<string>('DB_NAME'),
        autoLoadEntities: true,
        synchronize: true,
        ssl: {
          rejectUnauthorized: false,
        },
      }),
    }),

    // 3. Feature Modules
    GardenModule,
    WeatherModule,
    AuthModule,
    FirebaseModule,
    OtpModule,
    UserModule,
    PasswordModule,
    DiseaseModule,
    MarketplaceModule,

    // 4. Seller Hub & Profile Features
    SupabaseModule,
    ProfileModule,
    NotificationsModule,
    ReviewsModule,
    TermsModule,
    SupportModule,
    SellerModule,
    PreferencesModule,
    SubscriptionsModule,
    ProductsModule,
    SalesModule,
    SellersModule,
    BeneficiariesModule,
    StreaksModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }