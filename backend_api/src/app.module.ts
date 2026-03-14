import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { OtpModule } from './otp/otp.module';
import { FirebaseModule } from './firebase/firebase.module';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';

@Module({
  imports: [
    // Load the Config Module first — makes .env available everywhere
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    // Firebase Admin SDK (global — FirebaseService injectable everywhere)
    FirebaseModule,

    // Auth routes: /auth/login-otp, /auth/signup-otp, /auth/verify-otp, etc.
    OtpModule,
    AuthModule,
    UserModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}