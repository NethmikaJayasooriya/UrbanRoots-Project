import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

// root
import { AppController } from './app.controller';
import { AppService } from './app.service';

// core domains
import { GardenModule } from './garden/garden.module';
import { WeatherModule } from './weather/weather.module';
import { DiseaseModule } from './disease/disease.module';

// auth stack
import { AuthModule } from './auth/auth.module';
import { FirebaseModule } from './firebase/firebase.module';
import { OtpModule } from './otp/otp.module';
import { PasswordModule } from './password/password.module';
import { UserModule } from './user/user.module';

// marketplace
import { MarketplaceModule } from './marketplace/marketplace.module';

// user profile & seller hub mods
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
    // load envs
    ConfigModule.forRoot({ isGlobal: true }),

    // db init
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

    // feature mods
    GardenModule,
    WeatherModule,
    AuthModule,
    FirebaseModule,
    OtpModule,
    UserModule,
    PasswordModule,
    DiseaseModule,
    MarketplaceModule,

    // seller & profile mods
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