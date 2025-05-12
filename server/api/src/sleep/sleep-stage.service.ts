import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { SleepStageLog } from './entities/sleep-stage-log.entity';
import { Repository, EntityManager } from 'typeorm';
import { SleepStageDto } from './dto/upload-sleep-stage.request.dto';

@Injectable()
export class SleepStageService {
  constructor(
    @InjectRepository(SleepStageLog)
    private readonly stageRepo: Repository<SleepStageLog>,
  ) {}

  async saveStages(
    stages: SleepStageDto[],
    reportId: number,
    manager: EntityManager,
  ): Promise<void> {
    const stageEntities = stages.map((stage) => {
      const start = new Date(stage.startTime);
      const end = new Date(stage.endTime);

      return this.stageRepo.create({
        sleepReportId: reportId,
        stageType: stage.stageType,
        stageStartTime: start,
        stageEndTime: end,
        durationMinutes: Math.floor((end.getTime() - start.getTime()) / 60000),
      });
    });

    await manager.save(stageEntities);
  }

  private parseTime(timeStr: string, baseDate: Date): Date {
    const [hour, minute] = timeStr.split(':').map(Number);
    const result = new Date(baseDate);
    result.setHours(hour, minute, 0, 0);
    if (result < baseDate) result.setDate(result.getDate() + 1);
    return result;
  }
}
