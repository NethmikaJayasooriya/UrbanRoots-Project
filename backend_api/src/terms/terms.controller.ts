import { Body, Controller, Get, Post } from '@nestjs/common';
import { TermsService } from './terms.service';
import { AcceptTermsDto } from './dto/accept-terms.dto';

@Controller('terms')
export class TermsController {
  constructor(private readonly termsService: TermsService) {}

  @Get('current')
  getCurrentTerms() {
    return this.termsService.getCurrentTerms();
  }

  @Post('accept')
  acceptTerms(@Body() dto: AcceptTermsDto) {
    return this.termsService.acceptTerms(dto);
  }
}
