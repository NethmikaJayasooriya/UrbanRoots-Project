import { Body, Controller, Get, Post, Headers, UnauthorizedException } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';

@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  private extractUid(uid?: string): string {
    if (!uid) throw new UnauthorizedException('x-user-id header is required');
    return uid;
  }

  @Get('me')
  getMySubscription(@Headers('x-user-id') uid: string) {
    return this.subscriptionsService.getMySubscription(this.extractUid(uid));
  }

  @Post('start-membership')
  startMembership(
    @Headers('x-user-id') uid: string,
    @Body()
    body: {
      selectedPlan: string;
      paymentMethod: string;
    },
  ) {
    return this.subscriptionsService.startMembership(this.extractUid(uid), body);
  }
}
