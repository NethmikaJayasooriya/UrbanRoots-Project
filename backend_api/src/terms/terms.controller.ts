import { Body, Controller, Get, Post, Headers, UnauthorizedException } from '@nestjs/common';
import { TermsService } from './terms.service';
import { AcceptTermsDto } from './dto/accept-terms.dto';

@Controller('terms')
export class TermsController {
  constructor(private readonly termsService: TermsService) {}

  private extractUid(uid?: string): string {
    if (!uid) throw new UnauthorizedException('x-user-id header is required');
    return uid;
  }

  @Get('current')
  getCurrentTerms(@Headers('x-user-id') uid: string) {
    return this.termsService.getCurrentTerms(this.extractUid(uid));
  }

  @Post('accept')
  acceptTerms(@Headers('x-user-id') uid: string, @Body() dto: AcceptTermsDto) {
    return this.termsService.acceptTerms(this.extractUid(uid), dto);
  }
}
