import { SleepReport } from 'src/sleep-reports/entities/sleep-report.entity';
import {
  Column,
  Entity,
  CreateDateColumn,
  Index,
  PrimaryColumn,
  ManyToOne,
  JoinColumn,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('sleep_sounds')
export class SleepSound {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => SleepReport, (report) => report.sounds, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'sleep_report_id' })
  sleepReport: SleepReport;

  @Column({ name: 'voice_url', type: 'varchar', length: 255 })
  voiceUrl: string;

  @Column({ name: 'has_anomaly', type: 'boolean', default: false })
  hasAnomaly: boolean;

  @Column({ name: 'inference_completed', type: 'boolean', default: false })
  inferenceCompleted: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @Column({ name: 'duration', type: 'float' })
  duration: number;

  @Column({ type: 'uuid' })
  @Index({ unique: true })
  segmentId: string;
}
