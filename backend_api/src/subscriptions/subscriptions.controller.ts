import { Body, Controller, Get, Post } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';

@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  @Get('me')
  getMySubscription() {
    return this.subscriptionsService.getMySubscription();
  }

  @Post('start-membership')
  startMembership(
    @Body()
    body: {
      selectedPlan: string;
      paymentMethod: string;
    },
  ) {
    return this.subscriptionsService.startMembership(body);
  }
}
