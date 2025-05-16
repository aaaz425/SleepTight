import { Injectable } from '@nestjs/common';
import { SleepStageLog } from './entities/sleep-stage-log.entity';
import { SleepStageDto } from './dto/end-sleep.request.dto';

@Injectable()
export class SleepStageFactory {
  create(dto: SleepStageDto, reportId: number): SleepStageLog {
    const start = new Date(dto.startTime);
    const end = new Date(dto.endTime);

    const stage = new SleepStageLog();
    stage.sleepReportId = reportId;
    stage.stageType = dto.stageType;
    stage.stageStartTime = start;
    stage.stageEndTime = end;
    stage.durationMinutes = Math.floor(
      (end.getTime() - start.getTime()) / 60000,
    );

    return stage;
  }
}
