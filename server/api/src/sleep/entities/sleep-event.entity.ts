import { Column, Entity, PrimaryGeneratedColumn } from "typeorm";

@Entity('sleep_events')
export class SleepEvent {
    @PrimaryGeneratedColumn()
    id :number;
    
    @Column({name: 'segment_id', type: 'uuid' })
    segmentId: string;

    @Column({ name: 'start_sec', type: 'float' })
    startSec: number;

    @Column({name: 'end_sec', type: 'float' })
    endSec: number;

    @Column({name: 'inference_ts', type: 'timestamp' })
    inferenceTs: Date;

    @Column({ type: 'varchar' })
    anomaly: string;

    @Column({ type: 'int' })
    confidence: number;
}