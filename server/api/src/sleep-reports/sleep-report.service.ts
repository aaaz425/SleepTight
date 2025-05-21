import { SleepSoundFactory } from './../sleep-sound/sleep-sound.factory';
import { SleepSoundService } from './../sleep-sound/sleep-sound.service';
import { SleepReportFactory } from './sleep-report.factory';
import {
  BadRequestException,
  Inject,
  Injectable,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource, EntityManager, Between } from 'typeorm';
import { SleepReport } from './entities/sleep-report.entity';
import { SleepStageService } from 'src/sleep-reports/sleep-stage.service';
import { EndSleepRequestDto } from 'src/sleep-reports/dto/end-sleep.request.dto';
import { StartSleepRequestDto } from './dto/start-sleep.request.dto';
import { User } from 'src/users/entities/user.entity';
import { throwNotFoundException } from 'src/common/exceptions/exception.helper';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';
import { SleepStageLog } from './entities/sleep-stage-log.entity';
import { SleepDiariesService } from './sleep-diaries.service';
import { SleepSound } from 'src/sleep-sound/entities/sleep-sound.entity';

@Injectable()
export class SleepReportService {
  private readonly logger = new Logger(SleepReportService.name);

  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(SleepReport)
    private readonly reportRepo: Repository<SleepReport>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly sleepStageService: SleepStageService,
    private readonly reportFactory: SleepReportFactory,
    private readonly sleepSoundService: SleepSoundService,
    @InjectRepository(SleepStageLog)
    private readonly stageRepo: Repository<SleepStageLog>,
    @Inject(SleepDiariesService)
    private readonly sleepDiariesService: SleepDiariesService,
    private readonly sleepSoundFactory: SleepSoundFactory,
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

    // KST 기준으로 변환
    function getKSTDateOnly(date: Date): Date {
      const kstOffset = 9 * 60 * 60 * 1000;
      const kstDate = new Date(date.getTime() + kstOffset);
      return new Date(
        Date.UTC(kstDate.getFullYear(), kstDate.getMonth(), kstDate.getDate()),
      );
    }

    const sleepDateOnly = getKSTDateOnly(sleepDate);

    // 리포트 생성
    const newReport = this.reportFactory.createNew(
      userId,
      sleepStartTime,
      sleepDateOnly,
    );
    newReport.targetStartTime = user.sleep_time;
    newReport.targetEndTime = user.wake_time;
    newReport.isValidReport = false;

    // 저장 후 리포트 ID 반환
    const saved = await this.reportFactory.save(newReport);
    return saved.id;
  }

  // 수면 단계별 총 시간 저장
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

    this.logger.debug('Stage duration mins:', {
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

      // ⚠️ 유효수면 1시간 판단 임시 주석 처리
      const isValidSleep = true; // 1시간 판단 시 해당 줄 삭제 후 아래 주석 해제
      // const isValidSleep = sleepDurationMs >= 60 * 60 * 1000; // 1시간 이상이면 유효 수면
      report.isValidReport = isValidSleep;

      if (isValidSleep) {
        report.totalSleepTime = `${Math.floor(sleepDurationMs / 1000 / 60)} minutes`;

        // await this.sleepStageService.saveStages(dto.stages, report.id, manager);
        // await this.setStageDurations(report, manager);
        await this.saveStagesAndDurations(dto, report, manager);

        const firstStageStart =
          await this.sleepStageService.getFirstSleepStageStartTime(
            report.id,
            manager,
          );

        if (firstStageStart) {
          const latencyMs =
            firstStageStart.getTime() - report.sleepStartTime.getTime();
          if (latencyMs > 0) {
            report.sleepLatency = `${Math.floor(latencyMs / 1000 / 60)} minutes`;
          }
        }

        this.logger.debug('sleep latency:', {
          sleepLatency: report.sleepLatency,
        });
        const sounds = await this.sleepSoundFactory.findWithEventsByReportId(
          report.id,
        );
        this.logger.debug(
          `🧪 [DEBUG] Found ${sounds.length} sleep sounds for report ${report.id}`,
        );
        for (const sound of sounds) {
          this.logger.debug(
            `  └ segmentId: ${sound.segmentId}, events: ${sound.events?.length ?? 0}`,
          );
          for (const event of sound.events || []) {
            this.logger.debug(
              `🔹 Event - label: ${event.anomaly}, duration: ${event.endSec - event.startSec}`,
            );
          }
        }
        const { snoring, somniloquy, coughing } =
          this.sleepSoundService.calculateTotalDurationsFromSounds(sounds);

        report.snoringDurationSeconds = snoring;
        report.somniloquyDurationSeconds = somniloquy;
        report.coughingDurationSeconds = coughing;
      } else {
        report.totalSleepTime = null;
      }

      this.logger.debug('🐛 report before save:', {
        snoring: report.snoringDurationSeconds,
        somniloquy: report.somniloquyDurationSeconds,
        coughing: report.coughingDurationSeconds,
      });
      await manager.save(report);

      // 수면 일지 자동 생성
      await this.sleepDiariesService.createPartialFromReport(report);

      return isValidSleep;
    });

    return result;
  }
  private async saveStagesAndDurations(
    dto: EndSleepRequestDto,
    report: SleepReport,
    manager: EntityManager,
  ): Promise<void> {
    await this.sleepStageService.saveStages(dto.stages, report.id, manager);
    await this.setStageDurations(report, manager);
  }

  // 해당 일자의 수면로그 갖고오기
  async getReportsByDateWithStages(
    userId: number,
    date: string,
  ): Promise<any[]> {
    // const targetDate = new Date(date);
    // if (!date || isNaN(targetDate.getTime())) {
    //   throw new BadRequestException(ExceptionCode.INVALID_DATE_FORMAT);
    // }
    // const reports = await this.reportRepo.find({
    //   where: {
    //     userId,
    //     isValidReport: true,
    //     sleepDate: targetDate,
    //   },
    //   order: { sleepEndTime: 'DESC' },
    // });

    // KST 기준으로 범위 구하기
    function getKSTRange(date: Date): { start: Date; end: Date } {
      const kstOffset = 9 * 60 * 60 * 1000;

      const kstDate = new Date(date.getTime() + kstOffset);
      const start = new Date(
        Date.UTC(kstDate.getFullYear(), kstDate.getMonth(), kstDate.getDate()),
      );
      const end = new Date(start.getTime() + 24 * 60 * 60 * 1000 - 1);

      return { start, end };
    }

    const inputDate = new Date(date);
    const { start, end } = getKSTRange(inputDate);

    const reports = await this.reportRepo.find({
      where: {
        userId,
        isValidReport: true,
        sleepDate: Between(start, end),
      },
      order: { sleepEndTime: 'DESC' },
    });

    const result = await Promise.all(
      reports.map(async (report) => {
        const stages = await this.stageRepo.find({
          where: { sleepReportId: report.id },
          order: { stageStartTime: 'ASC' },
        });
        return {
          sleepReportId: report.id,
          sleep_start_time: report.sleepStartTime,
          sleep_end_time: report.sleepEndTime,
          sleep_latency: report.sleepLatency,
          total_awake_time: report.totalAwakeTime,
          total_rem_sleep_time: report.totalRemSleepTime,
          total_light_sleep_time: report.totalLightSleepTime,
          total_deep_sleep_time: report.totalDeepSleepTime,
          awaken_count: report.awakenCount,
          sleep_stage: stages.map((s) => ({
            stageType: s.stageType,
            startTime: s.stageStartTime,
            endTime: s.stageEndTime,
            duration: s.durationMinutes,
          })),
        };
      }),
    );

    return result;
  }

  // 리포트 ID로 수면 이벤트 조회
  async getSleepEventsByReportId(reportId: number, manager?: EntityManager) {
    const usedManager = manager ?? this.sleepSoundFactory.getManager();
    return this.sleepSoundService.getSleepEventsByReportId(
      reportId,
      usedManager,
    );
  }

  // 월별 수면 리포트가 존재하는 날짜 조회 (KST 기준)
  async getReportDaysInMonth(
    userId: number,
    year: number,
    month: number,
  ): Promise<number[]> {
    function getKSTRangeForMonth(
      year: number,
      month: number,
    ): { start: Date; end: Date } {
      const KST_OFFSET = 9 * 60 * 60 * 1000;

      const startUTC = new Date(Date.UTC(year, month - 1, 1));
      const endUTC = new Date(Date.UTC(year, month, 0, 23, 59, 59, 999));

      return {
        start: new Date(startUTC.getTime() - KST_OFFSET),
        end: new Date(endUTC.getTime() - KST_OFFSET),
      };
    }

    const { start, end } = getKSTRangeForMonth(year, month);

    const reports = await this.reportRepo.find({
      where: {
        userId,
        isValidReport: true,
        sleepDate: Between(start, end),
      },
    });

    // KST 기준 날짜 추출
    const dateList = reports.map((r) => {
      const sleepDate = new Date(r.sleepDate);
      const kst = new Date(sleepDate.getTime() + 9 * 60 * 60 * 1000);
      return kst.getDate();
    });

    return [...new Set(dateList)].sort((a, b) => a - b);
  }
}
