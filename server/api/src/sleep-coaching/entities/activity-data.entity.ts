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

  @Column({name: 'user_id'})
  userId: number;

  @Column({
    name: 'uuid',
    type: 'uuid',
    nullable: true,
  })
  uuid: string;

  @Column({
    name: 'data_type',
    type: 'enum',
    enum: ActivityDataType,
  })
  dataType: ActivityDataType;

  // 수치 데이터
  @Column({
    name: 'value_number',
    type: 'float',
    nullable: true,
  })
  valueNumber: number;

  // 복합 데이터
  @Column({
    name: 'value_json',
    type: 'jsonb',
    nullable: true,
  })
  valueJson: Record<string, any>;

  @Column({
    name: 'unit',
    type: 'enum',
    enum: ActivityUnit,
    nullable: true,
  })
  unit: ActivityUnit;

  @Column({ 
    name: 'activity_start_time', 
    type: 'timestamptz' })
  activityStartTime: Date;

  @Column({ 
    name: 'activity_end_time',
    type: 'timestamptz' })
  activityEndTime: Date;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;
}
