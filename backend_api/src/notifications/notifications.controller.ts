import { Controller, Get, Param, Patch } from '@nestjs/common';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get('me')
  getMyNotifications() {
    return this.notificationsService.getMyNotifications();
  }

  @Patch(':id/read')
  markOneRead(@Param('id') id: string) {
    return this.notificationsService.markOneRead(id);
  }

  @Patch('me/read-all')
  markAllRead() {
    return this.notificationsService.markAllRead();
  }
}
