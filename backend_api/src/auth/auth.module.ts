import { Module } from '@nestjs/common';
import { FirebaseModule } from '../firebase/firebase.module';
import { OtpModule } from '../otp/otp.module';
import { UserModule } from '../user/user.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
  imports: [
    OtpModule, 
    FirebaseModule, 
    UserModule // ADD THIS LINE INSTEAD OF SUPABASEMODULE
  ],
  controllers: [AuthController],
  providers: [AuthService],
  exports: [AuthService],
})
export class AuthModule {}