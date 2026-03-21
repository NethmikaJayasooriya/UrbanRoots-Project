import { BadRequestException, Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';
import { CreateSupportTicketDto } from './dto/create-support-ticket.dto';

const TEST_USER_ID = '11111111-1111-1111-1111-111111111111';

@Injectable()
export class SupportService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async createTicket(dto: CreateSupportTicketDto) {
    const category = dto.category?.trim() || null;
    const subject = dto.subject?.trim() || '';
    const message = dto.message?.trim() || '';

    if (!subject) {
      throw new BadRequestException('Subject is required');
    }

    if (!message) {
      throw new BadRequestException('Message is required');
    }

    const { data, error } = await this.supabaseService.client
      .from('support_tickets')
      .insert({
        user_id: TEST_USER_ID,
        category,
        subject,
        message,
        status: 'open',
      })
      .select('*')
      .single();

    if (error) {
      throw new Error(error.message);
    }

    return {
      message: 'Support ticket created successfully',
      ticket: data,
    };
  }

  async getMyTickets() {
    const { data, error } = await this.supabaseService.client
      .from('support_tickets')
      .select('*')
      .eq('user_id', TEST_USER_ID)
      .order('created_at', { ascending: false });

    if (error) {
      throw new Error(error.message);
    }

    return data ?? [];
  }

  async getAllFaqs() {
    const { data, error } = await this.supabaseService.client
      .from('support_faqs')
      .select('*')
      .eq('is_published', true)
      .order('created_at', { ascending: true });

    if (error) {
      throw new Error(error.message);
    }

    return data ?? [];
  }

  async searchFaqs(query?: string) {
    const trimmedQuery = query?.trim() || '';

    if (!trimmedQuery) {
      return this.getAllFaqs();
    }

    const { data, error } = await this.supabaseService.client
      .from('support_faqs')
      .select('*')
      .eq('is_published', true)
      .or(
        `question.ilike.%${trimmedQuery}%,answer.ilike.%${trimmedQuery}%,category.ilike.%${trimmedQuery}%`,
      )
      .order('created_at', { ascending: true });

    if (error) {
      throw new Error(error.message);
    }

    return data ?? [];
  }
}
