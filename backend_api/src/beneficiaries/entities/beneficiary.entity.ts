import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('beneficiaries')
export class Beneficiary {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  seller_id: string;

  @Column({ type: 'varchar' })
  full_name: string;

  @Column({ type: 'varchar' })
  account_number: string;

  @Column({ type: 'varchar' })
  bank: string;

  @CreateDateColumn({ type: 'timestamptz' })
  created_at: Date;
}
