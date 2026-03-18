import { Controller, Put, Body, Param, HttpCode, HttpStatus, BadRequestException } from '@nestjs/common';
import { UserService, UpdateProfileDto } from './user.service';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Put(':uid/profile')
  @HttpCode(HttpStatus.OK)
  async updateProfile(
    @Param('uid') uid: string,
    @Body() body: UpdateProfileDto,
  ) {
    if (!uid) {
      throw new BadRequestException('UID is required.');
    }
    return this.userService.updateProfile(uid, body);
  }
}
