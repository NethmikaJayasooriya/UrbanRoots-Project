import { Body, Controller, Get, Patch, Headers, UnauthorizedException } from '@nestjs/common';
import { PreferencesService } from './preferences.service';

@Controller('preferences')
export class PreferencesController {
  constructor(private readonly preferencesService: PreferencesService) {}

  private extractUid(uid?: string): string {
    if (!uid) throw new UnauthorizedException('x-user-id header is required');
    return uid;
  }

  @Get('me')
  getMyPreferences(@Headers('x-user-id') uid: string) {
    return this.preferencesService.getMyPreferences(this.extractUid(uid));
  }

  @Patch('me')
  updateMyPreferences(
    @Headers('x-user-id') uid: string,
    @Body() body: { smart_reminders?: boolean },
  ) {
    return this.preferencesService.updateMyPreferences(this.extractUid(uid), body);
  }
}
