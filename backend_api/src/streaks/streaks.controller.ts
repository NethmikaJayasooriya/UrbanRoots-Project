import { Controller, Get, Post } from '@nestjs/common';
import { StreaksService } from './streaks.service';

@Controller('streaks')
export class StreaksController {
  constructor(private readonly streaksService: StreaksService) {}

  @Get('me')
  getMyStreak() {
    return this.streaksService.getMyStreak();
  }

  @Post('complete-today')
  completeToday() {
    return this.streaksService.completeToday();
  }
}
