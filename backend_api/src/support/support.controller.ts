import { Body, Controller, Get, Post, Query, Headers, UnauthorizedException } from '@nestjs/common';
import { SupportService } from './support.service';
import { CreateSupportTicketDto } from './dto/create-support-ticket.dto';

@Controller('support')
export class SupportController {
  constructor(private readonly supportService: SupportService) {}

  private extractUid(uid?: string): string {
    if (!uid) throw new UnauthorizedException('x-user-id header is required');
    return uid;
  }

  @Post('tickets')
  createTicket(@Headers('x-user-id') uid: string, @Body() dto: CreateSupportTicketDto) {
    return this.supportService.createTicket(this.extractUid(uid), dto);
  }

  @Get('tickets/me')
  getMyTickets(@Headers('x-user-id') uid: string) {
    return this.supportService.getMyTickets(this.extractUid(uid));
  }

  @Get('faqs')
  getAllFaqs() {
    return this.supportService.getAllFaqs();
  }

  @Get('faqs/search')
  searchFaqs(@Query('q') q?: string) {
    return this.supportService.searchFaqs(q);
  }
}
