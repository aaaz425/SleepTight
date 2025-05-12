import { Expose } from "class-transformer";
import { SleepEvent } from "../entities/sleep-event.entity";

export class AnalysisResultDto {
    @Expose({ name: 'segment_id' })
    segmentId: string;
    @Expose({ name: 'start_sec' })
    startSec: number;
    @Expose({ name: 'end_sec' })
    endSec: number;
    @Expose({ name: 'inference_ts' })
    inferenceTs: Date;

    anomaly: string;

    confidence: number;

    static toEntity(dto: AnalysisResultDto) :SleepEvent{
        const sleepEvent: SleepEvent = new SleepEvent();
        sleepEvent.segmentId = dto.segmentId;
        sleepEvent.startSec = dto.startSec;
        sleepEvent.endSec = dto.endSec;
        sleepEvent.inferenceTs = dto.inferenceTs;
        sleepEvent.anomaly = dto.anomaly;
        sleepEvent.confidence = dto.confidence;
        return sleepEvent;
    }
}