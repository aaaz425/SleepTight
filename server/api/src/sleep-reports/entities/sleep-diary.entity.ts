import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    ManyToOne,
    JoinColumn,
  } from 'typeorm';
  import { SleepReport } from './sleep-report.entity';
  
  export enum WakeAwareness {
    NO = '아니요',
    NORMAL = '보통',
    YES = '네',
  }
  
  export enum WakeMethod {
    ALARM = '알람',
    BY_PERSON = '누군가 깨움',
    SELF = '스스로 일어남',
    NOISE = '소음',
    OTHER = '기타',
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
    sleepDate: string;    // YYYY-MM-DD
  
    @Column({ name: 'sleep_time', type: 'time' })
    sleepTime: string;    // HH:MM:SS
  
    @Column({ name: 'wake_time', type: 'time' })
    wakeTime: string;     // HH:MM:SS
  
    @Column({ name: 'sleep_latency', type: 'int' })
    sleepLatency: any; // 분
  
    @Column({ name: 'wake_count', type: 'int' })
    wakeCount: number;
  
    @Column({ name: 'sleep_quality', type: 'smallint' })
    sleepQuality: number; // 1~7 정도의 척도
  
    @Column({ name: 'mood_score', type: 'smallint' })
    moodScore: number;    // 1~7 정도의 척도
  
    @Column({
      name: 'wake_awareness',
      type: 'enum',
      enum: WakeAwareness,
    })
    wakeAwareness: WakeAwareness;
  
    @Column({
      name: 'wake_method',
      type: 'enum',
      enum: WakeMethod,
    })
    wakeMethod: WakeMethod;
  
    @Column({ name: 'wake_method_etc', type: 'text', nullable: true })
    wakeMethodEtc?: string;
  }
  