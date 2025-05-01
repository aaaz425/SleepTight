import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 20, nullable: true })
  provider: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  serial_number: string | null;

  @Column({ type: 'varchar', length: 255 })
  email: string;

  @Column({ type: 'time', default: '07:00', nullable: true })
  wake_time: string | null;

  @Column({ type: 'time', default: '23:00', nullable: true })
  sleep_time: string | null;

  @Column({ type: 'interval', default: '8 hours', nullable: true })
  min_sleep_duration: string | null;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  @CreateDateColumn({ type: 'timestamp' })
  visited_at: Date;

  @Column({ type: 'smallint', nullable: true })
  weight: number | null;

  @Column({ type: 'smallint', nullable: true })
  height: number | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  refresh_token: string | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  status: string | null;

  @Column({ type: 'timestamp', nullable: true })
  withdrawal_at: Date | null;

  @Column({ type: 'timestamp', nullable: true })
  dormant_at: Date | null;

  @Column({ type: 'date', nullable: true })
  birth_date: Date | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  last_name: string | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  first_name: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  gender: string | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  nationality: string | null;

  @Column({ type: 'varchar', length: 10, nullable: true })
  length_unit: string | null; // 예: 'cm', 'ft'
  
  @Column({ type: 'varchar', length: 10, nullable: true })
  weight_unit: string | null; // 예: 'kg', 'lb'
}