import { SleepReport } from 'src/sleep-reports/entities/sleep-report.entity';
import {
  Column,
  Entity,
  CreateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { SleepEvent } from './sleep-event.entity';

@Entity('sleep_sounds')
export class SleepSound {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => SleepReport, (report) => report.sounds, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'sleep_report_id' })
  sleepReport: number;

  @Column({ name: 'voice_url', type: 'varchar', length: 255 })
  voiceUrl: string;

  @Column({ name: 'has_anomaly', type: 'boolean', default: false })
  hasAnomaly: boolean;

  @Column({ name: 'inference_completed', type: 'boolean', default: false })
  inferenceCompleted: boolean;

  @Column({ name: 'start_time', type: 'timestamptz' })
  startTime: Date;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @Column({ name: 'duration', type: 'float' })
  duration: number;

  @Column({ name: 'segment_id', type: 'uuid' })
  @Index({ unique: true })
  segmentId: string;

  events?: SleepEvent[]; // 조인 시 가상으로 매핑할 필드
}
