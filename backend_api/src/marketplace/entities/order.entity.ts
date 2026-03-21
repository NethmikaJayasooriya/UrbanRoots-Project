<<<<<<< HEAD
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('order')
=======
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('orders')
>>>>>>> 1823ea291d5656955397d4cf7d7e5d97a1b06878
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

<<<<<<< HEAD
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
=======
  @Column({ type: 'uuid', nullable: true })
  userId: string; // The buyer

  @Column('decimal', { precision: 10, scale: 2 })
  totalPrice: number;

  @Column({ default: 'pending' })
  status: string;

  @Column({ type: 'jsonb' })
  items: any; // Contains an array of cart items

  @CreateDateColumn({ type: 'timestamp with time zone' })
>>>>>>> 1823ea291d5656955397d4cf7d7e5d97a1b06878
  createdAt: Date;
}
