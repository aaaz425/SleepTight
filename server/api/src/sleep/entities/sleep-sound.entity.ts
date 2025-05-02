import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
} from 'typeorm';
import { VoiceType } from './voice-type.enum';

@Entity('sleep_sounds')
export class SleepSound {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'sleep_report_id', type: 'int' })
  sleepReportId: number;

  @Column({ name: 'voice_url', type: 'varchar', length: 255 })
  voiceUrl: string;

  @Column({ name: 'voice_type', type: 'enum', enum: VoiceType })
  voiceType: VoiceType;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp with time zone' })
  createdAt: Date;

  @Column({ name: 'segment_id', type: 'uuid' })
  segmentId: string;

  @Column({ name: 'duration', type: 'float' })
  duration: number;
}
