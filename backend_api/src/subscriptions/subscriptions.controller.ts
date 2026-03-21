import { Body, Controller, Get, Patch } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';

@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  @Get('me')
  getMySubscription() {
    return this.subscriptionsService.getMySubscription();
  }

  @Patch('me')
  updateMySubscription(@Body() body: { selectedPlan?: string }) {
    return this.subscriptionsService.updateMySubscription(body);
  }
}
