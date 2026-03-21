import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

// Existing Apps
import { AppController } from './app.controller';
import { AppService } from './app.service';

// Feature Modules (From your merge)
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

@Module({
  imports: [
    // Load environment variables
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    // Connect to your Database (IoT Data Storage)
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('DB_HOST'),
        port: configService.get<number>('DB_PORT') || 5432,
        username: configService.get<string>('DB_USERNAME'),
        password: configService.get<string>('DB_PASSWORD'),
        database: configService.get<string>('DB_NAME'),
        autoLoadEntities: true,
        synchronize: true, // Auto-creates tables based on your code
      }),
    }),

    // All your specific modules
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
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }