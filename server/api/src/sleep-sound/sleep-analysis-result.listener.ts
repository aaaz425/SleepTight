import { Controller, Inject } from "@nestjs/common";
import { Ctx, EventPattern, Payload, RmqContext } from "@nestjs/microservices";
import { AnalysisResultDto } from "./dto/analysis-result.dto";
import { SleepSoundService } from "./sleep-sound.service";
import { SleepEvent } from "./entities/sleep-event.entity";
import { plainToInstance } from "class-transformer";
import { AnomalyType } from "./sleep-anomaly.enum";
import { Repository } from "typeorm";
import { InjectRepository } from "@nestjs/typeorm";

@Controller()
export class SleepAnalysisResultListener {
    constructor(

        private readonly sleepSoundService :SleepSoundService,
        @InjectRepository(SleepEvent)
        private readonly sleepEventRepository :Repository<SleepEvent>,
    ){}
    
    @EventPattern('analysis.result') //라우팅키
    async handleAnalysisResult (@Payload() data :any) {
        const events = data.events;
        const segmentId = data.segmentId;
        const inferenceTs = data.inferenceTs;
        let preLable: string = '';
        let preId: number = 0;

        for(const item of events) {
            const dto: AnalysisResultDto = plainToInstance(AnalysisResultDto, item); //Payload는 POJO이기 때문에 자동으로 변환이 되지 않음.
            dto.segmentId = segmentId;
            dto.inferenceTs = inferenceTs;
            try {
                //호흡은 제외하고 나머지 이상징후 저장
                if(dto.label!==AnomalyType.BREATHE) {

                    if(preLable === dto.label) { //이상징후가 이전과 같으면 이전 endSec를 업데이트
                        this.sleepEventRepository.update(preId, {
                            endSec: dto.end
                        });
                    } else { //이상징후가 이전과 다르면 새로운 이상징후 저장
                        const sleepEvent: SleepEvent = await AnalysisResultDto.toSleepEventEntity(dto);
                        const savedSleepEvent: SleepEvent = await this.sleepEventRepository.save(sleepEvent);
                        preLable = dto.label;
                        preId = savedSleepEvent.id;
                    }
                } else {
                    //호흡의 경우 이전 라벨만 바꿔줌
                    preLable = dto.label;
                }
            } catch (e) {
                console.error('Error processing analysis result:', e);
            }
        }
    }
}
