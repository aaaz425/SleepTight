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

  @Column({ name: 'sleep_preferences', type: 'jsonb', nullable: true })
  sleepPreferences: {
    targetSleepTime: string; // "HH:MM" 형식
    targetWakeTime: string; // "HH:MM" 형식
    timezone: string; // "Asia/Seoul"로 고정
  };

  @Column({ type: 'interval', default: '8 hours', nullable: false })
  min_sleep_duration: string;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  @CreateDateColumn({ type: 'timestamp' })
  visited_at: Date;

  @Column({ type: 'numeric', precision: 5, scale: 2, nullable: true })
  weight: number | null;

  @Column({ type: 'numeric', precision: 5, scale: 2, nullable: true })
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

  @Column({ name: 'weight_unit', type: 'varchar', length: 10, nullable: true })
  weight_unit: string | null; // 예: 'kg', 'lb'

  @Column({ name: 'fcm_token', type: 'varchar', length: 255, nullable: true })
  fcm_token: string | null;
  // SleepReport와 연결
  @OneToMany(() => SleepReport, (report) => report.user)
  sleepReports: SleepReport[];

  // 이전 버전과의 호환성을 위한 getter
  get sleep_time(): string {
    return this.sleepPreferences?.targetSleepTime || null;
  }

  get wake_time(): string {
    return this.sleepPreferences?.targetWakeTime || null;
  }
}
