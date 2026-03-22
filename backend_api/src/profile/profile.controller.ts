import { Body, Controller, Get, Patch, Headers, UnauthorizedException } from '@nestjs/common';
import { ProfileService } from './profile.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Controller('profile')
export class ProfileController {
  constructor(private readonly profileService: ProfileService) {}

  private extractUid(uid?: string) {
    if (!uid) throw new UnauthorizedException('Missing x-user-id header');
    return uid;
  }

  @Get('me')
  getMyProfile(@Headers('x-user-id') uid: string) {
    return this.profileService.getMyProfile(this.extractUid(uid));
  }

  @Patch('me')
  updateMyProfile(
    @Headers('x-user-id') uid: string, 
    @Body() dto: UpdateProfileDto
  ) {
    return this.profileService.updateMyProfile(this.extractUid(uid), dto);
  }
}
