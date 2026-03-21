import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { SupportService } from './support.service';
import { CreateSupportTicketDto } from './dto/create-support-ticket.dto';

@Controller('support')
export class SupportController {
  constructor(private readonly supportService: SupportService) {}

  @Post('tickets')
  createTicket(@Body() dto: CreateSupportTicketDto) {
    return this.supportService.createTicket(dto);
  }

  @Get('tickets/me')
  getMyTickets() {
    return this.supportService.getMyTickets();
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
