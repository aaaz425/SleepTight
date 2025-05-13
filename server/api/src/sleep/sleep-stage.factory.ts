import { Injectable } from '@nestjs/common';
import { SleepStageLog } from './entities/sleep-stage-log.entity';
import { SleepStageDto } from './dto/upload-sleep-stage.request.dto';

@Injectable()
export class SleepStageFactory {
  create(dto: SleepStageDto, reportId: number): SleepStageLog {
    const start = new Date(dto.startTime);
    const end = new Date(dto.endTime);

    return {
      sleepReportId: reportId,
      stageType: dto.stageType,
      stageStartTime: start,
      stageEndTime: end,
      durationMinutes: Math.floor((end.getTime() - start.getTime()) / 60000),
    } as SleepStageLog;
  }
}
