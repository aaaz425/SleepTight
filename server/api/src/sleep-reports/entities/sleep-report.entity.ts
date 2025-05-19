import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { SleepSound } from 'src/sleep-sound/entities/sleep-sound.entity';
import { User } from 'src/users/entities/user.entity';
import { SleepStageLog } from 'src/sleep-reports/entities/sleep-stage-log.entity';

@Entity('sleep_reports')
export class SleepReport {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id', type: 'int' })
  userId: number;

  @Column({ name: 'sleep_start_time', type: 'timestamptz', nullable: true })
  sleepStartTime: Date;

  @Column({ name: 'sleep_end_time', type: 'timestamptz', nullable: true })
  sleepEndTime: Date;

  @Column({ name: 'target_start_time', type: 'time', nullable: true })
  targetStartTime: string;

  @Column({ name: 'target_end_time', type: 'time', nullable: true })
  targetEndTime: string;

  @Column({ name: 'total_sleep_time', type: 'interval', nullable: true })
  totalSleepTime: string | null;

  @Column({ name: 'sleep_latency', type: 'interval', nullable: true })
  sleepLatency: string;

  @Column({ name: 'total_awake_time', type: 'interval', nullable: true })
  totalAwakeTime: string;

  @Column({ name: 'total_rem_sleep_time', type: 'interval', nullable: true })
  totalRemSleepTime: string;

  @Column({ name: 'total_light_sleep_time', type: 'interval', nullable: true })
  totalLightSleepTime: string;

  @Column({ name: 'total_deep_sleep_time', type: 'interval', nullable: true })
  totalDeepSleepTime: string;

  @Column({ name: 'awaken_count', type: 'smallint', nullable: true })
  awakenCount: number;

  @Column({
    name: 'snoring_duration_seconds',
    type: 'int',
    nullable: true,
  })
  snoringDurationSeconds: number;

  @Column({
    name: 'somniloquy_duration_seconds',
    type: 'int',
    nullable: true,
  })
  somniloquyDurationSeconds: number;

  @Column({
    name: 'coughing_duration_seconds',
    type: 'int',
    nullable: true,
  })
  coughingDurationSeconds: number;

  @Column({ name: 'sleep_date', type: 'date' })
  sleepDate: Date;

  @Column({
    name: 'is_valid_report',
    type: 'boolean',
    default: false,
  })
  isValidReport: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;

  // User와 연결
  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  // SleepSound와 연결
  @OneToMany(() => SleepSound, (sound) => sound.sleepReport)
  sounds: SleepSound[];

  // SleepStageLog와 연결
  @OneToMany(() => SleepStageLog, (stage) => stage.sleepReport)
  stages: SleepStageLog[];
}
