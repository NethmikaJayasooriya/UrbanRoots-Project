import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, UpdateDateColumn,
} from 'typeorm';

@Entity('sellers')
export class Seller {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar' })
  uid: string;

  @Column({ type: 'varchar', nullable: true })
  brand_name: string;

  @Column({ type: 'varchar', nullable: true })
  business_email: string;

  @Column({ type: 'varchar', nullable: true })
  phone: string;

  @Column({ type: 'text', nullable: true })
  business_address: string;

  @Column({ type: 'text', nullable: true })
  logo_url: string;

  @Column({ type: 'varchar', nullable: true })
  account_name: string;

  @Column({ type: 'varchar', nullable: true })
  account_number: string;

  @Column({ type: 'varchar', nullable: true })
  bank: string;

  @Column({ type: 'varchar', nullable: true })
  branch: string;

  @Column({ type: 'numeric', precision: 3, scale: 2, default: 0 })
  rating: number;

  @Column({ type: 'boolean', default: false })
  is_verified: boolean;

  @CreateDateColumn({ type: 'timestamptz' })
  created_at: Date;

  @UpdateDateColumn({ type: 'timestamptz' })
  updated_at: Date;
}
