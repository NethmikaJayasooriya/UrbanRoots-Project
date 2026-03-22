import { Test, TestingModule } from '@nestjs/testing';
import { SupabaseService } from '../common/supabase/supabase.service';
import { StreaksService } from './streaks.service';

describe('StreaksService', () => {
  let service: StreaksService;
  let mockSupabase: any;

  beforeEach(async () => {
    mockSupabase = {
      client: {
        from: jest.fn().mockReturnThis(),
        select: jest.fn().mockReturnThis(),
        eq: jest.fn().mockReturnThis(),
        maybeSingle: jest.fn(),
        insert: jest.fn().mockReturnThis(),
        update: jest.fn().mockReturnThis(),
        single: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StreaksService,
        {
          provide: SupabaseService,
          useValue: mockSupabase,
        },
      ],
    }).compile();

    service = module.get<StreaksService>(StreaksService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('Pure Logic Tests', () => {
    it('returns default streak if db returns no data and insert fails', async () => {
      mockSupabase.client.maybeSingle.mockResolvedValue({ data: null, error: null });
      mockSupabase.client.single.mockResolvedValue({ data: null, error: new Error('Insert failed') });

      const result = await service.getOrCreateStreak('test-user');
      expect(result.current_streak).toBe(0);
      expect(result.longest_streak).toBe(0);
      expect(result.user_id).toBe('test-user');
    });

    it('resets streak to 0 if last_completed_date is older than yesterday', async () => {
      const dbDate = new Date();
      dbDate.setDate(dbDate.getDate() - 2); // 2 days ago
      
      const mockedStreak = {
        user_id: 'test-user',
        current_streak: 5,
        longest_streak: 5,
        last_completed_date: dbDate.toISOString().split('T')[0],
      };

      jest.spyOn(service, 'getOrCreateStreak').mockResolvedValue(mockedStreak as any);
      mockSupabase.client.single.mockResolvedValue({ data: { ...mockedStreak, current_streak: 0 }, error: null });

      const result = await service.getMyStreak('test-user');
      expect(result.current_streak).toBe(0);
    });

    it('alreadyCompletedToday should be true if last_completed_date is today', async () => {
      const today = new Date().toISOString().split('T')[0];
      const mockedStreak = {
        user_id: 'test-user',
        current_streak: 5,
        longest_streak: 5,
        last_completed_date: today,
      };

      jest.spyOn(service, 'getOrCreateStreak').mockResolvedValue(mockedStreak as any);

      const result = await service.completeToday('test-user');
      expect(result.alreadyCompletedToday).toBe(true);
      expect(result.current_streak).toBe(5);
    });
  });
});
