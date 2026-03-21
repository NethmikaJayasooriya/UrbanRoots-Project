import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Beneficiary } from './entities/beneficiary.entity';
import { BeneficiariesService } from './beneficiaries.service';
import { BeneficiariesController } from './beneficiaries.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Beneficiary])],
  providers: [BeneficiariesService],
  controllers: [BeneficiariesController],
})
export class BeneficiariesModule {}
