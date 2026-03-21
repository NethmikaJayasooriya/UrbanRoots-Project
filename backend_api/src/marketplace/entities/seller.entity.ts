import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('sellers')
export class Seller {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', unique: true })
  uid: string; // References public.users(uid)

  @Column({ name: 'brand_name', type: 'varchar', nullable: true })
  brandName: string;

  @Column({ name: 'business_email', type: 'varchar', nullable: true })
  businessEmail: string;

  @Column({ type: 'varchar', nullable: true })
  phone: string;

  @Column({ name: 'business_address', type: 'text', nullable: true })
  businessAddress: string;

  @Column({ name: 'logo_url', type: 'text', nullable: true })
  logoUrl: string;

  @Column({ name: 'account_name', type: 'varchar', nullable: true })
  accountName: string;

  @Column({ name: 'account_number', type: 'varchar', nullable: true })
  accountNumber: string;

  @Column({ type: 'varchar', nullable: true })
  bank: string;

  @Column({ type: 'varchar', nullable: true })
  branch: string;

  @Column({ type: 'numeric', precision: 3, scale: 2, default: 0 })
  rating: number;

  @Column({ name: 'is_verified', type: 'boolean', default: false })
  isVerified: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;
}
