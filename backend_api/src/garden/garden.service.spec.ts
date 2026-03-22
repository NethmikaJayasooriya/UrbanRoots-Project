import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { getRepositoryToken } from '@nestjs/typeorm';
import { WeatherService } from '../weather/weather.service';
import { ActiveCrop } from './active-crop.entity';
import { Garden } from './garden.entity';
import { GardenService } from './garden.service';

describe('GardenService', () => {
  let service: GardenService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        GardenService,
        {
          provide: getRepositoryToken(Garden),
          useValue: {
            create: jest.fn(),
            save: jest.fn(),
            findOne: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(ActiveCrop),
          useValue: {
            create: jest.fn(),
            save: jest.fn(),
            findOne: jest.fn(),
            find: jest.fn(),
            update: jest.fn(),
          },
        },
        {
          provide: WeatherService,
          useValue: {
            getLiveWeather: jest.fn(),
          },
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn().mockReturnValue('mocked-api-key'),
          },
        },
      ],
    }).compile();

    service = module.get<GardenService>(GardenService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  // Pure logic tests
  describe('processIoTAlert (Offline Unit Tests)', () => {
    it('should return strict fallback action if AI fails or times out', async () => {
      // Intentionally pass an alert type that has a built-in fallback
      const result = await service.processIoTAlert(1, {
        alert_type: 'frost',
        plant_name: 'tomato',
      });
      // Without mocking the AI positively, the try/catch or fallbacks will take over
      // Or we assert it matches the known fallback
      expect(result.care_action).toContain('Move indoors or cover with frost cloth');
      expect(result.pet_dialogue).toContain('Freezing!');
    });

    it('should return a generic fallback for unknown alerts', async () => {
      const result = await service.processIoTAlert(1, {
        alert_type: 'alien_invasion',
        plant_name: 'tomato',
      });
      expect(result.care_action).toBe("Check your plant's conditions immediately.");
    });
  });
});
