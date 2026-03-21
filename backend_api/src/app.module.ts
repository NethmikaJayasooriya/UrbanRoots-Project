import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { ProductsModule }      from './products/products.module';
import { SalesModule }         from './sales/sales.module';
import { SellersModule }       from './sellers/sellers.module';
import { BeneficiariesModule } from './beneficiaries/beneficiaries.module';
import { UsersModule }         from './users/users.module';

@Module({
  imports: [
    // ── Env ────────────────────────────────────────────────
    ConfigModule.forRoot({ isGlobal: true }),

    // ── Database ───────────────────────────────────────────
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        type: 'postgres',
        host:     cfg.get<string>('DB_HOST'),
        port:     cfg.get<number>('DB_PORT'),
        username: cfg.get<string>('DB_USER'),
        password: cfg.get<string>('DB_PASS'),
        database: cfg.get<string>('DB_NAME'),
        ssl: { rejectUnauthorized: false }, // required for Supabase
        autoLoadEntities: true,
        synchronize: false, // tables already exist in Supabase
      }),
    }),

    // ── Feature modules ────────────────────────────────────
    UsersModule,
    SellersModule,
    ProductsModule,
    SalesModule,
    BeneficiariesModule,
  ],
})
export class AppModule {}
