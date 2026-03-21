import { Module } from '@nestjs/common';
import { SupportController } from './support.controller';
import { SupportService } from './support.service';
import { SupabaseService } from '../common/supabase/supabase.service';

@Module({
  controllers: [SupportController],
  providers: [SupportService, SupabaseService],
})
export class SupportModule {}
