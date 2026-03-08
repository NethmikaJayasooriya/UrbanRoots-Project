import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('gardens')
export class Garden {
  @PrimaryGeneratedColumn()
  garden_id: number;

  @Column({ type: 'varchar', length: 255 })
  user_id: string;

  @Column({ type: 'varchar', length: 100 })
  garden_name: string;

  @Column({ type: 'varchar', length: 255 })
  location: string;

  @Column({ type: 'varchar', length: 50 })
  environment: string;

  @Column({ type: 'boolean', default: false })
  is_iot_connected: boolean;

  @Column({ type: 'varchar', length: 50, nullable: true })
  soil_type: string;

  @Column({ type: 'int', nullable: true })
  sunlight_level: number;

  @Column({ type: 'varchar', length: 50, nullable: true })
  watering_frequency: string;

  @Column({ type: 'boolean', default: false })
  is_windy: boolean;

  @Column({ type: 'varchar', length: 50 })
  container_size: string;

  @Column({ type: 'varchar', length: 50 })
  gardening_goal: string;

  @Column('text', { array: true })
  target_crops: string[];

  @Column({ type: 'varchar', length: 50 })
  experience_level: string;

  @CreateDateColumn()
  created_at: Date;
}