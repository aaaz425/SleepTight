import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity('sleep_coachings')
export class SleepCoaching {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'sleep_report_id', type: 'int', comment: '수면 리포트 아이디' })
  sleepReportId: number;

  @Column({ name: 'user_id', type: 'int', comment: '유저 아이디' })
  userId: number;

  @Column({ name: 'sleep_coaching_date', type: 'date' })
  sleepCoachingDate: Date;

  @Column({ type: 'varchar', length: 50 })
  activity: string;

  @Column({ type: 'varchar', length: 50 })
  type: string;

  @Column({ type: 'numeric', precision: 9, scale: 2,  nullable: true }) //백만까지 가능
  value: number;

  @Column({ type: 'text' })
  description: string;

  static responseToSleepCoaching(userId: number, sleepReportId: number, data :any): SleepCoaching {
    const sleepCoaching: SleepCoaching = new SleepCoaching();
    sleepCoaching.sleepReportId = sleepReportId;
    sleepCoaching.userId = userId;
    sleepCoaching.sleepCoachingDate = new Date();
    sleepCoaching.activity = data.activity;
    sleepCoaching.type = data.type;
    sleepCoaching.value = data.value;
    sleepCoaching.description = data.description;
    return sleepCoaching;
  }

}