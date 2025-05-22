import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { SleepReport } from './sleep-report.entity';

export enum WakeAwareness {
  NO = 'NO',
  NORMAL = 'NORMAL',
  YES = 'YES',
}

export enum WakeMethod {
  ALARM = 'ALARM',
  BY_PERSON = 'BY_PERSON',
  SELF = 'SELF',
  NOISE = 'NOISE',
  OTHER = 'OTHER',
}

@Entity('sleep_diaries')
export class SleepDiary {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'sleep_report_id', type: 'int' })
  sleepReportId: number;

  @ManyToOne(() => SleepReport, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'sleep_report_id' })
  sleepReport: SleepReport;

  @Column({ name: 'sleep_date', type: 'date' })
  sleepDate: string; // YYYY-MM-DD

  @Column({ name: 'sleep_time', type: 'time' })
  sleepTime: string; // HH:MM:SS

  @Column({ name: 'wake_time', type: 'time' })
  wakeTime: string; // HH:MM:SS

  @Column({ name: 'sleep_latency', type: 'interval', nullable: true })
  sleepLatency: any; // PostgreSQL interval 을 다루기 위해 any로 설정

  @Column({ name: 'wake_count', type: 'int', nullable: true })
  wakeCount: number;

  @Column({ name: 'sleep_quality', type: 'smallint', nullable: true })
  sleepQuality: number; // 1~7 정도의 척도

  @Column({ name: 'mood_score', type: 'smallint', nullable: true })
  moodScore: number; // 1~7 정도의 척도

  @Column({
    name: 'wake_awareness',
    type: 'enum',
    enum: WakeAwareness,
    nullable: true,
  })
  wakeAwareness: WakeAwareness;

  @Column({
    name: 'wake_method',
    type: 'enum',
    enum: WakeMethod,
    nullable: true,
  })
  wakeMethod: WakeMethod;

  @Column({ name: 'wake_method_etc', type: 'text', nullable: true })
  wakeMethodEtc?: string;
}
