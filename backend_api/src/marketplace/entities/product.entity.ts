<<<<<<< HEAD
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('product')
=======
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Seller } from './seller.entity';

@Entity('products')
>>>>>>> 1823ea291d5656955397d4cf7d7e5d97a1b06878
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

<<<<<<< HEAD
  @Column()
  name: string;

  @Column()
  category: string;

  @Column('float')
  price: number;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ nullable: true })
  imageUrl: string;

  @Column({ nullable: true })
  placeholderIcon: string; // Storing string representation of icons, e.g. 'spa_rounded'

  @CreateDateColumn()
  createdAt: Date;
=======
  @Column({ name: 'seller_id', type: 'uuid' })
  sellerId: string;

  @ManyToOne(() => Seller, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'seller_id' })
  seller: Seller;

  @Column({ type: 'text' })
  name: string;

  @Column({ type: 'text' })
  category: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'numeric', precision: 10, scale: 2 })
  price: number;

  @Column({ name: 'image_url', type: 'text', nullable: true })
  imageUrl: string;

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp with time zone' })
  updatedAt: Date;
>>>>>>> 1823ea291d5656955397d4cf7d7e5d97a1b06878
}
