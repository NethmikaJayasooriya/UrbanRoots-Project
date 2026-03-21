import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, ManyToOne, JoinColumn,
} from 'typeorm';
import { Product } from '../../products/entities/product.entity';

@Entity('sales')
export class Sale {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  product_id: string;

  @Column({ type: 'uuid' })
  seller_id: string;

  @Column({ type: 'integer', default: 1 })
  quantity: number;

  @Column({ type: 'numeric', precision: 10, scale: 2 })
  unit_price: number;

  @Column({ type: 'numeric', precision: 12, scale: 2 })
  total: number;

  @Column({ type: 'timestamptz' })
  sale_date: Date;

  @CreateDateColumn({ type: 'timestamptz' })
  created_at: Date;

  // ── Relation — for the join in getSales ───────────────────
  @ManyToOne(() => Product, { eager: false })
  @JoinColumn({ name: 'product_id' })
  product: Product;
}
