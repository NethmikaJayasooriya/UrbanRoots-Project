import { Controller, Get, Param, Patch, Headers, UnauthorizedException } from '@nestjs/common';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  private extractUid(uid?: string): string {
    if (!uid) throw new UnauthorizedException('x-user-id header is required');
    return uid;
  }

  @Get('me')
  getMyNotifications(@Headers('x-user-id') uid: string) {
    return this.notificationsService.getMyNotifications(this.extractUid(uid));
  }

  @Patch(':id/read')
  markOneRead(@Param('id') id: string, @Headers('x-user-id') uid: string) {
    return this.notificationsService.markOneRead(id, this.extractUid(uid));
  }

  @Patch('me/read-all')
  markAllRead(@Headers('x-user-id') uid: string) {
    return this.notificationsService.markAllRead(this.extractUid(uid));
  }
}
