import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { ActivityDataType } from './activity-data.enum';
import { ActivityUnit } from './activity-unit.enum';

@Entity('activity_data')
@Index(['userId', 'dataType', 'activityStartTime'])
export class ActivityData {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({
    name: 'data_type',
    type: 'enum',
    enum: ActivityDataType,
  })
  dataType: ActivityDataType;

  @Column({
    name: 'value_number',
    type: 'float',
    nullable: true,
  })
  valueNumber: number;

  @Column({
    name: 'unit',
    type: 'enum',
    enum: ActivityUnit,
    nullable: true,
  })
  unit: ActivityUnit;

  @Column({ name: 'activity_start_time', type: 'timestamptz' })
  activityStartTime: Date;

  @Column({ name: 'activity_end_time', type: 'timestamptz' })
  activityEndTime: Date;

  @Column({ name: 'report_date', type: 'date' })
  reportDate: Date; // 기준 수면 일자

  @CreateDateColumn({ name: 'creatd_at' })
  createdAt: Date;
}
