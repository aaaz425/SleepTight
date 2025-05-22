import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { SleepStageLog } from './entities/sleep-stage-log.entity';
import { Repository, EntityManager, In } from 'typeorm';
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

  // 수면단계 저장
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

  // 자는데 걸리는 시간 계산
  async getFirstSleepStageStartTime(
    reportId: number,
    manager: EntityManager,
  ): Promise<Date | null> {
    const firstStage = await manager.findOne(SleepStageLog, {
      where: {
        sleepReportId: reportId,
        stageType: In([
          SleepStageType.LIGHT,
          SleepStageType.DEEP,
          SleepStageType.REM,
        ]),
      },
      order: { stageStartTime: 'ASC' },
    });
    return firstStage?.stageStartTime ?? null;
  }
}
