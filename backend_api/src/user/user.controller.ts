import { Controller, Post, Put, Get, Body, Param, HttpCode, HttpStatus, BadRequestException } from '@nestjs/common';
import { UserService, UserProfileData } from './user.service';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) { }

  /**
   * Endpoint for initial Profile Setup after OTP verification.
   */
  @Post('setup-profile')
  @HttpCode(HttpStatus.OK)
  async setupProfile(
    @Body('uid') uid: string,
    @Body('firstName') firstName: string,
    @Body('lastName') lastName: string,
    @Body('email') email: string,
    @Body('phone') phone?: string,
    @Body('authProvider') authProvider?: string,
    @Body('profilePic') profilePic?: string,
    @Body('is_seller') is_seller?: boolean,
  ) {
    if (uid === undefined || firstName === undefined || lastName === undefined || email === undefined) {
      throw new BadRequestException('uid, firstName, lastName, and email are required for profile setup.');
    }

    await this.userService.updateProfile(uid, {
      firstName,
      lastName,
      email,
      phone,
      authProvider,
      profilePic,
      is_seller: is_seller ?? false,
      is_onboarded: true,
    });
    return { success: true, message: 'Profile setup complete' };
  }

  /**
   * Endpoint for editing the profile later on. Profile picture is optional.
   */
  @Put('edit-profile')
  @HttpCode(HttpStatus.OK)
  async editProfile(
    @Body('uid') uid: string,
    @Body() profileData: UserProfileData,
  ) {
    if (!uid) {
      throw new BadRequestException('uid is required to edit profile.');
    }

    // Remove uid from profileData so we don't accidentally save it as a field if passed
    const { ...dataToUpdate } = profileData;
    delete (dataToUpdate as any).uid;

    if (Object.keys(dataToUpdate).length === 0) {
      throw new BadRequestException('No valid fields provided to update.');
    }

    await this.userService.updateProfile(uid, dataToUpdate);
    return { success: true, message: 'Profile updated successfully' };
  }

  /**
   * Endpoint for user to become a seller from the Seller Hub portal.
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
    if (!uid) {
      throw new BadRequestException('uid is required');
    }
    const profile = await this.userService.getProfile(uid);
    return { success: true, data: profile };
  }
}
