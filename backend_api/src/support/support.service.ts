import { BadRequestException, Injectable } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';
import { CreateSupportTicketDto } from './dto/create-support-ticket.dto';

@Injectable()
export class SupportService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async createTicket(uid: string, dto: CreateSupportTicketDto) {
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
        user_id: uid,
        category,
        subject,
        message,
        status: 'open',
      })
      .select('*')
      .single();

    if (error) {
      if (error.message?.includes('invalid input syntax for type uuid')) {
        throw new BadRequestException('User ID format is not compatible with the database. Please contact support.');
      }
      throw new Error(error.message);
    }

    return {
      message: 'Support ticket created successfully',
      ticket: data,
    };
  }

  async getMyTickets(uid: string) {
    const { data, error } = await this.supabaseService.client
      .from('support_tickets')
      .select('*')
      .eq('user_id', uid)
      .order('created_at', { ascending: false });

    // Supabase user_id column is uuid type; Firebase UIDs are not UUIDs
    // Return empty list gracefully instead of crashing with 500
    if (error) {
      if (error.message?.includes('invalid input syntax for type uuid')) {
        return [];
      }
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
