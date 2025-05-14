import { Controller, Inject } from "@nestjs/common";
import { Ctx, EventPattern, Payload, RmqContext } from "@nestjs/microservices";
import { AnalysisResultDto } from "./dto/analysis-result.dto";
import { SleepSoundService } from "./sleep-sound.service";
import { ConfigService } from "@nestjs/config";
import { SleepEvent } from "./entities/sleep-event.entity";
import { plainToInstance } from "class-transformer";

@Controller()
export class SleepAnalysisResultListener {
    constructor(
        private readonly sleepSoundService :SleepSoundService,
    ){}
    
    @EventPattern('analysis.result') //라우팅키
    async handleAnalysisResult (@Payload() data :any) {
        const dto = plainToInstance(AnalysisResultDto, data); //Payload는 POJO이기 때문에 자동으로 변환이 되지 않음.
        try {
            const sleepEventEntity :SleepEvent = AnalysisResultDto.toEntity(dto);
            await this.sleepSoundService.saveSleepEvent(sleepEventEntity);
        } catch (e) {
            //TODO: 에러난 경우 어떻게 처리할지?
            //에러가 나면 다시 큐에 넣어주는 방법도 있음.
            console.error('Failed to save sleep event:', e);
        }
    }
}
