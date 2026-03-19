import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { Garden } from './garden.entity';

@Entity('active_crops')
export class ActiveCrop {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  garden_id: number;

  @Column()
  plant_name: string;

  @Column({ default: 'Healthy' })
  status: string;

  // Stores the AI-calculated checklist of tasks
  @Column({ type: 'jsonb', nullable: true })
  daily_tasks: any;

  // Determines if the Digital Pet is currently monitoring this specific plant
  @Column({ default: false })
  is_linked_to_pet: boolean;

  @ManyToOne(() => Garden, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'garden_id' })
  garden: Garden;
}