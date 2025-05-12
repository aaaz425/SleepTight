import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { SleepSound } from 'src/sleep/entities/sleep-sound.entity';
import { User } from 'src/users/entities/user.entity';
import { SleepStageLog } from 'src/sleep/entities/sleep-stage-log.entity';

@Entity('sleep_reports')
export class SleepReport {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id', type: 'int' })
  userId: number;

  @Column({ name: 'sleep_start_time', type: 'timestamp', nullable: true })
  sleepStartTime: Date;

  @Column({ name: 'sleep_end_time', type: 'timestamp', nullable: true })
  sleepEndTime: Date;

  @Column({ name: 'target_start_time', type: 'time', nullable: true })
  targetStartTime: string;

  @Column({ name: 'target_end_time', type: 'time', nullable: true })
  targetEndTime: string;

  @Column({ name: 'total_sleep_time', type: 'interval', nullable: true })
  totalSleepTime: any;

  @Column({ name: 'total_awake_time', type: 'interval', nullable: true })
  totalAwakeTime: any;

  @Column({ name: 'total_rem_sleep_time', type: 'interval', nullable: true })
  totalRemSleepTime: any;

  @Column({ name: 'total_light_sleep_time', type: 'interval', nullable: true })
  totalLightSleepTime: any;

  @Column({ name: 'total_deep_sleep_time', type: 'interval', nullable: true })
  totalDeepSleepTime: any;

  @Column({ name: 'awaken_count', type: 'smallint', nullable: true })
  awakenCount: number;

  @Column({ name: 'average_heart_rate', type: 'smallint', nullable: true })
  averageHeartRate: number;

  @Column({ name: 'min_spo2', type: 'smallint', nullable: true })
  minSpo2: number;

  @Column({ name: 'max_spo2', type: 'smallint', nullable: true })
  maxSpo2: number;

  @Column({
    name: 'snoring_duration_minutes',
    type: 'interval',
    nullable: true,
  })
  snoringDurationMinutes: any;

  @Column({ name: 'sleep_score', type: 'smallint', nullable: true })
  sleepScore: number;

  @Column({ name: 'disturbance_count', type: 'smallint', nullable: true })
  disturbanceCount: number;

  @Column({ name: 'sleep_date', type: 'date', nullable: false })
  sleepDate: Date;

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
