import {
  Entity, PrimaryColumn, Column,
  CreateDateColumn, UpdateDateColumn,
} from 'typeorm';

@Entity('users')
export class User {
  @PrimaryColumn({ type: 'varchar' })
  uid: string;

  @Column({ type: 'varchar', nullable: true })
  first_name: string;

  @Column({ type: 'varchar', nullable: true })
  last_name: string;

  @Column({ type: 'varchar', nullable: true })
  email: string;

  @Column({ type: 'varchar', nullable: true })
  phone: string;

  @Column({ type: 'varchar', nullable: true })
  auth_provider: string;

  @Column({ type: 'varchar', nullable: true })
  profile_pic: string;

  @Column({ type: 'boolean', default: false })
  is_onboarded: boolean;

  @Column({ type: 'boolean', default: false })
  is_seller: boolean;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updated_at: Date;
}
