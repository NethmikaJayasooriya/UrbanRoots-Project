import { Test, TestingModule } from '@nestjs/testing';
import { GardenController } from './garden.controller';
import { GardenService } from './garden.service';

describe('GardenController', () => {
  let controller: GardenController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [GardenController],
      providers: [
        {
          provide: GardenService,
          useValue: {
            createGarden: jest.fn(),
            getGardenByUserId: jest.fn(),
            getGardenStatus: jest.fn(),
            generateCropRecommendations: jest.fn(),
            addCropToGarden: jest.fn(),
            getGardenCrops: jest.fn(),
            linkPlantToPet: jest.fn(),
            updateCropTasks: jest.fn(),
            processIoTAlert: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<GardenController>(GardenController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
