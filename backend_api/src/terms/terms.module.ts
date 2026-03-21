import { Module } from '@nestjs/common';
import { TermsController } from './terms.controller';
import { TermsService } from './terms.service';
import { SupabaseService } from '../common/supabase/supabase.service';

@Module({
  controllers: [TermsController],
  providers: [TermsService, SupabaseService],
})
export class TermsModule {}
