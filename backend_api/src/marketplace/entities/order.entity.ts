import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ nullable: true })
  orderId: string; // e.g. ORD-12345

  @Column({ nullable: true })
  customerPhone: string;

  @Column('jsonb', { nullable: true })
  customerDetails: any;

  @Column('jsonb')
  items: any[];

  @Column('float', { nullable: true })
  totalAmount: number;

  @Column({ nullable: true })
  paymentMethod: string;

  @Column({ default: 'PENDING' })
  status: string;

  @Column({ type: 'uuid', nullable: true })
  userId: string;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;
}
