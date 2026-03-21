import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', nullable: true })
  userId: string; // The buyer

  @Column('decimal', { precision: 10, scale: 2 })
  totalPrice: number;

  @Column({ default: 'pending' })
  status: string;

  @Column({ type: 'jsonb' })
  items: any; // Contains an array of cart items

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;
}
