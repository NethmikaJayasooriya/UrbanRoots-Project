import { Column, CreateDateColumn, Entity, PrimaryColumn, UpdateDateColumn } from 'typeorm';

@Entity('users') // This automatically creates the 'users' table in Supabase
export class User {
  @PrimaryColumn()
  uid: string; // The Firebase UID is used as the primary key!

  @Column({ nullable: true })
  first_name: string;

  @Column({ nullable: true })
  last_name: string;

  @Column({ nullable: true })
  email: string;

  @Column({ nullable: true })
  phone: string;

  @Column({ nullable: true })
  auth_provider: string;

  @Column({ nullable: true })
  profile_pic: string;

  @Column({ default: false })
  is_onboarded: boolean;

  @Column({ default: false })
  is_seller: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}