import {
  Entity, PrimaryGeneratedColumn, Column, CreateDateColumn,
} from 'typeorm';

@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'orderId', type: 'varchar', nullable: true })
  orderId: string; // e.g. ORD-12345

  @Column({ name: 'customerPhone', type: 'varchar', nullable: true })
  customerPhone: string;

  @Column({ name: 'customerDetails', type: 'json', nullable: true })
  customerDetails: any;

  @Column({ name: 'items', type: 'json', nullable: true })
  items: any[];

  @Column({ name: 'totalAmount', type: 'numeric', precision: 10, scale: 2, nullable: true })
  totalAmount: number;

  @Column({ name: 'paymentMethod', type: 'varchar', nullable: true })
  paymentMethod: string;

  @Column({ name: 'status', type: 'varchar', default: 'PENDING', nullable: true })
  status: string;

  @Column({ name: 'userId', type: 'varchar', nullable: true })
  userId: string;

  @CreateDateColumn({ name: 'createdAt', type: 'timestamp with time zone' })
  createdAt: Date;
}
