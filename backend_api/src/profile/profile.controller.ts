import { Body, Controller, Get, Patch } from '@nestjs/common';
import { ProfileService } from './profile.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Controller('profile')
export class ProfileController {
  constructor(private readonly profileService: ProfileService) {}

  @Get('me')
  getMyProfile() {
    return this.profileService.getMyProfile();
  }

  @Patch('me')
  updateMyProfile(@Body() dto: UpdateProfileDto) {
    return this.profileService.updateMyProfile(dto);
  }
}
