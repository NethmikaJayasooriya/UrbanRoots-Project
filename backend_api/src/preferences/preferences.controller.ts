import { Body, Controller, Get, Patch } from '@nestjs/common';
import { PreferencesService } from './preferences.service';

@Controller('preferences')
export class PreferencesController {
  constructor(private readonly preferencesService: PreferencesService) {}

  @Get('me')
  getMyPreferences() {
    return this.preferencesService.getMyPreferences();
  }

  @Patch('me')
  updateMyPreferences(@Body() body: { smart_reminders?: boolean }) {
    return this.preferencesService.updateMyPreferences(body);
  }
}
