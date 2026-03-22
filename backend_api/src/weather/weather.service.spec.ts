import { Test, TestingModule } from '@nestjs/testing';
import { WeatherService } from './weather.service';

import { HttpService } from '@nestjs/axios';
import { of } from 'rxjs';

describe('WeatherService', () => {
  let service: WeatherService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WeatherService,
        {
          provide: HttpService,
          useValue: {
            get: jest.fn(() => of({ data: {} })),
          },
        },
      ],
    }).compile();

    service = module.get<WeatherService>(WeatherService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
