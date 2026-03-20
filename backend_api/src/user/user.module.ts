import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserController } from './user.controller';
<<<<<<< HEAD
import { User } from './user.entity';
import { UserService } from './user.service';

@Module({
  // Import the TypeORM feature so the service can access the database
  imports: [TypeOrmModule.forFeature([User])], 
=======
import { UserService } from './user.service';
import { User } from './entities/user.entity';
import { FirebaseModule } from '../firebase/firebase.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([User]),
    FirebaseModule,
  ],
>>>>>>> origin/Feature/profile-dashboard
  controllers: [UserController],
  providers: [UserService],
  exports: [UserService],
})
<<<<<<< HEAD
export class UserModule {}
=======
export class UserModule {}
>>>>>>> origin/Feature/profile-dashboard
