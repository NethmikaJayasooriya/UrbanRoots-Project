import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('order')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  orderId: string; // e.g. ORD-12345

  @Column({ nullable: true })
  customerPhone: string; // Used for order tracking

  @Column('jsonb')
  customerDetails: any; // name, address, phone

  @Column('jsonb')
  items: any[];

  @Column('float')
  totalAmount: number;

  @Column()
  paymentMethod: string;

  @Column({ default: 'PENDING' })
  status: string;

  @CreateDateColumn()
  createdAt: Date;
}
