import { Controller, Inject } from "@nestjs/common";
import { Ctx, EventPattern, Payload, RmqContext } from "@nestjs/microservices";
import { AnalysisResultDto } from "./dto/analysis-result.dto";
import { SleepSoundService } from "./sleep-sound.service";
import { SleepEvent } from "./entities/sleep-event.entity";
import { plainToInstance } from "class-transformer";
import { AnomalyType } from "./sleep-anomaly.enum";

@Controller()
export class SleepAnalysisResultListener {
    constructor(
        private readonly sleepSoundService :SleepSoundService,
    ){}
    
    @EventPattern('analysis.result') //라우팅키
    async handleAnalysisResult (@Payload() data :any) {
        const events = data.events;
        const segmentId = data.segmentId;
        const inferenceTs = data.inferenceTs;

        for(const item of events) {
            const dto: AnalysisResultDto = plainToInstance(AnalysisResultDto, item); //Payload는 POJO이기 때문에 자동으로 변환이 되지 않음.
            dto.segmentId = segmentId;
            dto.inferenceTs = inferenceTs;
            try {
                //호흡은 제외하고 나머지 이상징후 저장
                if(dto.label!==AnomalyType.BREATHE) {
                    const sleepEvent :SleepEvent = await AnalysisResultDto.toSleepEventEntity(dto);
                    await this.sleepSoundService.saveSleepEvent(sleepEvent);
                }
            } catch (e) {
                console.error('Error processing analysis result:', e);
            }
        }


    }
}
