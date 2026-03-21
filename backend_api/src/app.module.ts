import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { SupabaseModule } from './common/supabase/supabase.module';
import { ProfileModule } from './profile/profile.module';
import { NotificationsModule } from './notifications/notifications.module';
import { ReviewsModule } from './reviews/reviews.module';
import { TermsModule } from './terms/terms.module';
import { SupportModule } from './support/support.module';
import { SellerModule } from './seller/seller.module';
import { PreferencesModule } from './preferences/preferences.module';
import { SubscriptionsModule } from './subscriptions/subscriptions.module';
import { StreaksModule } from './streaks/streaks.module';
<<<<<<< HEAD

import { UserModule } from './user/user.module';
import { FirebaseModule } from './firebase/firebase.module';
import { User } from './user/entities/user.entity';

@Module({
  imports: [
<<<<<<< HEAD
=======

@Module({
  imports: [
>>>>>>> b1868ab (save remaining profile dashboard changes)
    ConfigModule.forRoot({ isGlobal: true }),
    SupabaseModule,
    ProfileModule,
    NotificationsModule,
    ReviewsModule,
    TermsModule,
    SupportModule,
    SellerModule,
    PreferencesModule,
    SubscriptionsModule,
    StreaksModule,
<<<<<<< HEAD
=======
    //Load the Config Module first
    ConfigModule.forRoot({
      isGlobal: true, // Makes .env available everywhere
    }),

    //Connect to Database using the variables
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('DB_HOST'),
        port: configService.get<number>('DB_PORT'),
        username: configService.get<string>('DB_USERNAME'),
        password: configService.get<string>('DB_PASSWORD'),
        database: configService.get<string>('DB_NAME'),
        entities: [User],
        synchronize: true,
      }),
    }),

    UserModule,
    FirebaseModule,
>>>>>>> e58905b0f1a824cbe080fcb14f8709f217b345ea
=======
>>>>>>> b1868ab (save remaining profile dashboard changes)
  ],
})
export class AppModule {}
