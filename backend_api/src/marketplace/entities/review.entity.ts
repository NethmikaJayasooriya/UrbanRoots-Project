import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

@Entity('reviews')
export class Review {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'productId', type: 'uuid' })
  productId: string;

  @Column({ default: 'User' })
  author: string;

  @Column('int')
  rating: number;

  @Column({ type: 'text', nullable: true })
  comment: string;

  @CreateDateColumn({ name: 'createdAt', type: 'timestamp with time zone' })
  createdAt: Date;
}
