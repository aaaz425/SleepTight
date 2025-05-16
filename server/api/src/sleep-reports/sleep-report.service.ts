import { SleepSoundService } from './../sleep-sound/sleep-sound.service';
import { SleepReportFactory } from './sleep-report.factory';
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource, EntityManager } from 'typeorm';
import { SleepReport } from './entities/sleep-report.entity';
import { SleepStageService } from 'src/sleep-reports/sleep-stage.service';
import { EndSleepRequestDto } from 'src/sleep-reports/dto/end-sleep.request.dto';
import { StartSleepRequestDto } from './dto/start-sleep.request.dto';
import { User } from 'src/users/entities/user.entity';
import { throwNotFoundException } from 'src/common/exceptions/exception.helper';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';

@Injectable()
export class SleepReportService {
  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(SleepReport)
    private readonly reportRepo: Repository<SleepReport>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly sleepStageService: SleepStageService,
    private readonly reportFactory: SleepReportFactory,
    private readonly sleepSoundService: SleepSoundService,
  ) {}

  // 수면 시작
  async startSleep(userId: number, dto: StartSleepRequestDto): Promise<number> {
    const sleepStartTime = new Date(dto.sleep_start_time);

    const user = await this.userRepo.findOneBy({ id: userId });
    if (!user) {
      throwNotFoundException(ExceptionCode.USER_NOT_FOUND);
    }

    // 목표 기상 시간 기준 sleepDate 계산 (UTC)
    const [wakeHourStr, wakeMinuteStr] = user.wake_time.split(':');
    const wakeDateTime = new Date(sleepStartTime);
    wakeDateTime.setUTCHours(
      parseInt(wakeHourStr, 10),
      parseInt(wakeMinuteStr, 10),
      0,
      0,
    );

    const sleepDate = new Date(sleepStartTime);
    if (sleepStartTime < wakeDateTime) {
      sleepDate.setUTCDate(sleepDate.getUTCDate() - 1);
    }

    const sleepDateOnly = new Date(
      Date.UTC(
        sleepDate.getUTCFullYear(),
        sleepDate.getUTCMonth(),
        sleepDate.getUTCDate(),
      ),
    );

    // 기존 유효하지 않은 리포트가 있다면 재사용
    const existing = await this.reportRepo.findOne({
      where: {
        userId,
        isValidReport: false,
      },
      order: { createdAt: 'DESC' },
    });

    if (existing) {
      existing.sleepStartTime = sleepStartTime;
      existing.sleepDate = sleepDateOnly;
      existing.isValidReport = true;
      existing.targetStartTime = user.sleep_time;
      existing.targetEndTime = user.wake_time;
      return (await this.reportRepo.save(existing)).id;
    }

    // 없으면 리포트 새로 생성
    const newReport = this.reportFactory.createNew(
      userId,
      sleepStartTime,
      sleepDateOnly,
    );
    newReport.sleepDate = sleepDateOnly;
    newReport.targetStartTime = user.sleep_time;
    newReport.targetEndTime = user.wake_time;
    newReport.totalSleepTime = user.min_sleep_duration;

    // 저장 후 리포트 ID 반환
    const saved = await this.reportFactory.save(newReport);
    return saved.id;
  }

  private async setStageDurations(
    report: SleepReport,
    manager: EntityManager,
  ): Promise<void> {
    const { awake, light, deep, rem, awakenCount } =
      await this.sleepStageService.calculateStageDurations(report.id, manager);

    report.totalAwakeTime = `${awake} minutes`;
    report.totalLightSleepTime = `${light} minutes`;
    report.totalDeepSleepTime = `${deep} minutes`;
    report.totalRemSleepTime = `${rem} minutes`;
    report.awakenCount = awakenCount;

    console.log('Stage duration mins:', {
      awake,
      light,
      deep,
      rem,
      awakenCount,
    });
  }

  // 수면 종료 + 수면 단계 업로드
  async endSleep(dto: EndSleepRequestDto): Promise<boolean> {
    const result = await this.dataSource.transaction(async (manager) => {
      // 종료 시간 계산
      const report = await manager.findOne(SleepReport, {
        where: { id: dto.reportId },
      });
      if (!report) throwNotFoundException(ExceptionCode.REPORT_NOT_FOUND);

      const sleepEndTime = new Date(dto.sleepEndTime);
      report.sleepEndTime = sleepEndTime;

      const sleepDurationMs =
        sleepEndTime.getTime() - report.sleepStartTime.getTime();
      const isValidSleep = sleepDurationMs >= 60 * 60 * 1000; // 1시간 이상이면 유효 수면
      report.isValidReport = isValidSleep;

      if (isValidSleep) {
        report.totalSleepTime = `${Math.floor(sleepDurationMs / 60)} minutes`;

        await this.sleepStageService.saveStages(dto.stages, report.id, manager);
        await this.setStageDurations(report, manager);

        const { snoring, somniloquy, coughing } =
          await this.sleepSoundService.calculateEventDurations(
            report.id,
            manager,
          );
        report.snoringDurationSeconds = snoring;
        report.somniloquyDurationSeconds = somniloquy;
        report.coughingDurationSeconds = coughing;
      } else {
        report.totalSleepTime = null;
      }
      console.log('🐛 report before save:', {
        snoring: report.snoringDurationSeconds,
        somniloquy: report.somniloquyDurationSeconds,
        coughing: report.coughingDurationSeconds,
      });
      await manager.save(report);
      return isValidSleep;
    });

    return result;
  }
}
