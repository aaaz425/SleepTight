import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { SleepStageLog } from './entities/sleep-stage-log.entity';
import { Repository, EntityManager } from 'typeorm';
import { SleepStageDto } from './dto/end-sleep.request.dto';
import { SleepStageFactory } from './sleep-stage.factory';
import { SleepStageType } from './entities/sleep-stage-type.enum';

@Injectable()
export class SleepStageService {
  constructor(
    @InjectRepository(SleepStageLog)
    private readonly stageRepo: Repository<SleepStageLog>,
    private readonly factory: SleepStageFactory,
  ) {}

  async saveStages(
    stages: SleepStageDto[],
    reportId: number,
    manager: EntityManager,
  ): Promise<void> {
    const stageEntities = stages.map((dto) =>
      this.factory.create(dto, reportId),
    );

    await manager.save(stageEntities);
  }

  // private parseTime(timeStr: string, baseDate: Date): Date {
  //   const [hour, minute] = timeStr.split(':').map(Number);
  //   const result = new Date(baseDate);
  //   result.setHours(hour, minute, 0, 0);
  //   if (result < baseDate) result.setDate(result.getDate() + 1);
  //   return result;
  // }

  // 수면 단계별 총 시간 계산
  async calculateStageDurations(
    reportId: number,
    manager: EntityManager,
  ): Promise<{
    awake: number;
    light: number;
    deep: number;
    rem: number;
    awakenCount: number;
  }> {
    const stages = await manager.find(SleepStageLog, {
      where: { sleepReportId: reportId },
    });

    let awake = 0,
      light = 0,
      deep = 0,
      rem = 0,
      awakenCount = 0;

    for (let i = 0; i < stages.length; i++) {
      const stage = stages[i];
      const enumValue = stage.stageType as SleepStageType;

      switch (enumValue) {
        case SleepStageType.AWAKE:
          awake += stage.durationMinutes;

          // 중간에 등장한 AWAKE만 카운트
          if (i !== 0 && i !== stages.length - 1) awakenCount++;
          break;

        case SleepStageType.LIGHT:
          light += stage.durationMinutes;
          break;

        case SleepStageType.DEEP:
          deep += stage.durationMinutes;
          break;

        case SleepStageType.REM:
          rem += stage.durationMinutes;
          break;
      }
    }
    console.log(
      '🔍 stages:',
      stages.map((s) => ({
        stageType: s.stageType,
        duration: s.durationMinutes,
      })),
    );
    return { awake, light, deep, rem, awakenCount };
  }
}
