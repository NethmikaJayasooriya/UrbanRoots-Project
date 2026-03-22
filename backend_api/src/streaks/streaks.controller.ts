import { Controller, Get, Post, Headers, UnauthorizedException } from '@nestjs/common';
import { StreaksService } from './streaks.service';

@Controller('streaks')
export class StreaksController {
  constructor(private readonly streaksService: StreaksService) {}

  private extractUid(uid?: string): string {
    if (!uid) throw new UnauthorizedException('x-user-id header is required');
    return uid;
  }

  @Get('me')
  getMyStreak(@Headers('x-user-id') uid: string) {
    return this.streaksService.getMyStreak(this.extractUid(uid));
  }

  @Post('complete-today')
  completeToday(@Headers('x-user-id') uid: string) {
    return this.streaksService.completeToday(this.extractUid(uid));
  }
}
