import { Expose } from "class-transformer";
import { SleepEvent } from "../entities/sleep-event.entity";

export class AnalysisResultDto {
    @Expose({ name: 'segment_id' })
    segmentId: string;
    @Expose({ name: 'start' })
    start: number;
    @Expose({ name: 'end' })
    end: number;
    @Expose({ name: 'inference_ts' })
    inferenceTs: Date;

    label: string;

    prob: number;

    static toSleepEventEntity(dto: AnalysisResultDto) :SleepEvent{
        const sleepEvent: SleepEvent = new SleepEvent();
        sleepEvent.segmentId = dto.segmentId;
        sleepEvent.startSec = dto.start;
        sleepEvent.endSec = dto.end;
        sleepEvent.inferenceTs = dto.inferenceTs;
        sleepEvent.anomaly = dto.label;
        sleepEvent.confidence = dto.prob;
        return sleepEvent;
    }
}