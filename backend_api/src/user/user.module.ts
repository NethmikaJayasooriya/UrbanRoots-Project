import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserController } from './user.controller';
import { User } from './user.entity';
import { UserService } from './user.service';

@Module({
  // Import the TypeORM feature so the service can access the database
  imports: [TypeOrmModule.forFeature([User])], 
  controllers: [UserController],
  providers: [UserService],
  exports: [UserService],
})
export class UserModule {}