import { SleepReport } from 'src/sleep-reports/entities/sleep-report.entity';
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  OneToMany,
} from 'typeorm';

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

  @Column({ type: 'time', default: '07:00', nullable: false })
  wake_time: string;

  @Column({ type: 'time', default: '23:00', nullable: false })
  sleep_time: string;

  @Column({ type: 'interval', default: '8 hours', nullable: false })
  min_sleep_duration: string;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  @CreateDateColumn({ type: 'timestamp' })
  visited_at: Date;

  @Column({ type: 'numeric', precision: 5, scale: 2,  nullable: true })
  weight: number | null;

  @Column({ type: 'numeric', precision: 5, scale: 2,  nullable: true })
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

  @Column({ name:'weight_unit', type: 'varchar', length: 10, nullable: true })
  weight_unit: string | null; // 예: 'kg', 'lb'

  @Column({ name: 'fcm_token', type:'varchar', length:255, nullable: true})
  fcm_token: string | null;
  // SleepReport와 연결
  @OneToMany(() => SleepReport, (report) => report.user)
  sleepReports: SleepReport[];
}
