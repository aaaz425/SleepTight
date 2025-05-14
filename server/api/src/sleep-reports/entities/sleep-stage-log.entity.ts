import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { SleepStageType } from './sleep-stage-type.enum';
import { SleepReport } from './sleep-report.entity';

@Entity('sleep_stage_logs')
export class SleepStageLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'sleep_report_id' })
  sleepReportId: number;

  @Column({ name: 'stage_type', type: 'enum', enum: SleepStageType })
  stageType: SleepStageType;

  @Column({ name: 'stage_start_time', type: 'timestamp' })
  stageStartTime: Date;

  @Column({ name: 'stage_end_time', type: 'timestamp' })
  stageEndTime: Date;

  @Column({ name: 'duration_minutes' })
  durationMinutes: number;

  // SleepReport와 연결
  @ManyToOne(() => SleepReport, (report) => report.stages, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'sleep_report_id' })
  sleepReport: SleepReport;
}
