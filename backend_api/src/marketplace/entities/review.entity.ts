<<<<<<< HEAD
import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('review')
=======
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Product } from './product.entity';

@Entity('reviews')
>>>>>>> 1823ea291d5656955397d4cf7d7e5d97a1b06878
export class Review {
  @PrimaryGeneratedColumn('uuid')
  id: string;

<<<<<<< HEAD
  @Column()
  productId: string; // The UUID of the product

  @Column({ default: 'User' })
  originalName: string;

  @Column()
  rating: number;

  @Column('text')
  comment: string;

  @CreateDateColumn()
=======
  @Column('uuid')
  productId: string;

  @ManyToOne(() => Product, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'productId' })
  product: Product;

  @Column()
  author: string;

  @Column('int')
  rating: number;

  @Column({ type: 'text', nullable: true })
  comment: string;

  @CreateDateColumn({ type: 'timestamp with time zone' })
>>>>>>> 1823ea291d5656955397d4cf7d7e5d97a1b06878
  createdAt: Date;
}
