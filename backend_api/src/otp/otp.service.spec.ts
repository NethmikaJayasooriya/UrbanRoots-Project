import { BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import { OtpService } from './otp.service';

jest.mock('nodemailer', () => ({
  createTransport: jest.fn().mockReturnValue({
    sendMail: jest.fn().mockResolvedValue(true),
  }),
}));

describe('OtpService', () => {
  let service: OtpService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OtpService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key) => {
              if (key === 'SMTP_SECURE') return false;
              if (key === 'SMTP_HOST') return 'localhost';
              if (key === 'SMTP_PORT') return 25;
              if (key === 'SMTP_USER') return 'test@test.com';
              if (key === 'SMTP_PASS') return 'pass';
              return null;
            }),
          },
        },
      ],
    }).compile();

    service = module.get<OtpService>(OtpService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('Pure Logic Tests', () => {
    it('generates an OTP and stores it in memory', async () => {
      await service.generateAndSendOtp('test@test.com');
      // @ts-ignore - access private member for testing
      const record = service.otpStore.get('test@test.com');
      expect(record).toBeDefined();
      expect(record!.otp.length).toBe(4);
    });

    it('returns false for invalid OTP', async () => {
      await service.generateAndSendOtp('test@test.com');
      // @ts-ignore
      const record = service.otpStore.get('test@test.com');
      const badOtp = record!.otp === '1234' ? '4321' : '1234';
      
      const result = await service.verifyOtp('test@test.com', badOtp);
      expect(result).toBe(false);
    });

    it('throws BadRequestException for expired OTP', async () => {
      await service.generateAndSendOtp('test@test.com');
      // @ts-ignore
      const record = service.otpStore.get('test@test.com');
      record!.expiresAt = new Date(Date.now() - 1000); // Expirated in the past
      
      await expect(service.verifyOtp('test@test.com', record!.otp)).rejects.toThrow(BadRequestException);
    });
  });
});
