import { Module } from '@nestjs/common';
import { FirebaseService } from './firebase.service';

@Module({
  providers: [FirebaseService],
  exports: [FirebaseService], // Export so UserService can use it
})
export class FirebaseModule {}
