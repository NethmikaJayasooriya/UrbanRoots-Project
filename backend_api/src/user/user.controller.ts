import { BadRequestException, Body, Controller, Get, HttpCode, HttpStatus, Param, Post, Put } from '@nestjs/common';
import { UpdateProfileDto, UserService } from './user.service';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) { }

  /**
   * Endpoint for initial Profile Setup after OTP verification.
   */
  @Post('setup-profile')
  @HttpCode(HttpStatus.OK)
  async setupProfile(@Body() profileData: UpdateProfileDto & { uid: string }) {
    const { uid, ...data } = profileData;
    if (!uid || !data.firstName || !data.lastName || !data.email) {
      throw new BadRequestException('uid, firstName, lastName, and email are required for profile setup.');
    }

    await this.userService.updateProfile(uid, {
      ...data,
      is_onboarded: true,
    });
    return { success: true, message: 'Profile setup complete' };
  }

  /**
   * Endpoint for editing the profile later on.
   */
  @Put('edit-profile')
  @HttpCode(HttpStatus.OK)
  async editProfile(
    @Body('uid') uid: string,
    @Body() profileData: UpdateProfileDto,
  ) {
    if (!uid) {
      throw new BadRequestException('uid is required to edit profile.');
    }
    await this.userService.updateProfile(uid, profileData);
    return { success: true, message: 'Profile updated successfully' };
  }

  /**
   * Endpoint for user to become a seller.
   */
  @Put('become-seller')
  @HttpCode(HttpStatus.OK)
  async becomeSeller(@Body('uid') uid: string) {
    if (!uid) {
      throw new BadRequestException('uid is required to become a seller.');
    }
    await this.userService.updateProfile(uid, { is_seller: true });
    return { success: true, message: 'User upgraded to seller account successfully' };
  }

  /**
   * Get user profile data.
   */
  @Get('profile/:uid')
  async getProfile(@Param('uid') uid: string) {
    const profile = await this.userService.getProfile(uid);
    return { success: true, data: profile };
  }
}