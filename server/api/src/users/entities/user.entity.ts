import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity('users') // 테이블 이름 명시
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 20, nullable: true })
  provider: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  serial_number: string;

  @Column({type: 'varchar', length: 50, nullable: false })
  name: string;

  @Column({ type: 'varchar', length: 255, nullable: false })
  email: string;

  @Column({ type: 'time', default: () => "'07:00'" })
  wake_time: string;

  @Column({ type: 'time', default: () => "'23:00'" })
  sleep_time: string;

  @Column({ type: 'interval', default: () => "'8 hours'" })
  min_sleep_duration: string; // PostgreSQL INTERVAL은 string 타입으로 매핑

  @Column({ type: 'timestamp', nullable: false })
  created_at: Date;

  @Column({ type: 'timestamp', nullable: false })
  visited_at: Date;

  @Column({ type: 'smallint', nullable: true })
  weight: number;

  @Column({ type: 'smallint', nullable: true })
  height: number;

  @Column({ type: 'varchar', length: 255, nullable: true })
  refresh_token: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  status: string;
}