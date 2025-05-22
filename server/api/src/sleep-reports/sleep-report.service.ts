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
import { SleepDiary } from './entities/sleep-diary.entity';

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

    // 사용자 시간대 설정 (기본값: Asia/Seoul)
    const userTimezone = user.sleepPreferences?.timezone || 'Asia/Seoul';

    // 사용자 수면 설정 가져오기 (없으면 기본값 사용)
    const targetWakeTime =
      user.sleepPreferences?.targetWakeTime || user.wake_time || '07:00';
    const [wakeHourStr, wakeMinuteStr] = targetWakeTime.split(':');

    // 수면 시작 시간을 사용자 시간대로 변환
    const options = { timeZone: userTimezone };
    const localTime = sleepStartTime.toLocaleString('en-US', options);
    const startDateInLocal = new Date(localTime);

    // 사용자 시간대 기준 목표 기상 시간 설정
    const wakeTimeInLocal = new Date(startDateInLocal);
    wakeTimeInLocal.setHours(
      parseInt(wakeHourStr, 10),
      parseInt(wakeMinuteStr, 10),
      0,
      0,
    );

    // 사용자 시간대 기준으로 수면 날짜 결정
    const sleepDateInLocal = new Date(startDateInLocal);
    if (startDateInLocal.getTime() < wakeTimeInLocal.getTime()) {
      // 수면 시작이 목표 기상 시간보다 이전이면 전날로 간주
      sleepDateInLocal.setDate(sleepDateInLocal.getDate() - 1);
    }

    // 날짜만 포함하는 UTC 기준 날짜 생성 (사용자 시간대의 날짜 기준)
    const sleepDateOnly = new Date(
      Date.UTC(
        sleepDateInLocal.getFullYear(),
        sleepDateInLocal.getMonth(),
        sleepDateInLocal.getDate(),
      ),
    );

    // 리포트 생성
    const newReport = this.reportFactory.createNew(
      userId,
      sleepStartTime,
      sleepDateOnly,
    );

    // 목표 시간 설정 (getter를 통해 접근)
    newReport.targetStartTime = user.sleep_time || '22:00';
    newReport.targetEndTime = user.wake_time || '07:00';
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
      this.logger.debug(
        `수면 일지 자동 생성 시작 - reportId: ${report.id}, 날짜: ${report.sleepDate}`,
      );
      try {
        const diary =
          await this.sleepDiariesService.createPartialFromReport(report);
        this.logger.debug(
          `수면 일지 생성 완료 - diaryId: ${diary.id}, reportId: ${report.id}`,
        );
      } catch (error) {
        this.logger.error(
          `수면 일지 생성 실패 - reportId: ${report.id}`,
          error,
        );
      }

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
    // 날짜 유효성 검사
    if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      throw new BadRequestException(ExceptionCode.INVALID_DATE_FORMAT);
    }

    const dateComponents = date.split('-').map(Number);

    // UTC 기준으로 날짜 범위 구하기 (00:00:00 ~ 23:59:59)
    const start = new Date(
      Date.UTC(dateComponents[0], dateComponents[1] - 1, dateComponents[2]),
    );
    const end = new Date(start.getTime() + 24 * 60 * 60 * 1000 - 1);

    this.logger.debug(`getReportsByDateWithStages: 검색 날짜 범위 UTC`, {
      startUTC: start.toISOString(),
      endUTC: end.toISOString(),
      dateString: date, // 요청된 날짜 문자열
    });

    // 정확히 해당 날짜만 포함하는 쿼리
    const reports = await this.reportRepo
      .createQueryBuilder('report')
      .where('report.user_id = :userId', { userId })
      .andWhere('report.is_valid_report = :isValid', { isValid: true })
      .andWhere('report.sleep_date = :date', {
        date: start.toISOString().split('T')[0],
      })
      .orderBy('report.sleep_end_time', 'DESC')
      .getMany();

    const reportCount = reports.length;
    this.logger.debug(`조회된 리포트 수: ${reportCount}`, {
      userId,
      date,
      reportCount,
    });

    const result = await Promise.all(
      reports.map(async (report) => {
        const stages = await this.stageRepo.find({
          where: { sleepReportId: report.id },
          order: { stageStartTime: 'ASC' },
        });

        // UTC 시간 그대로 사용 (KST 변환 제거)
        const sleepStages = stages.map((s) => ({
          stageType: s.stageType,
          startTime: s.stageStartTime,
          endTime: s.stageEndTime,
          duration: s.durationMinutes,
        }));

        this.logger.debug(
          `수면 단계 로그 - reportId: ${report.id}, 단계 수: ${stages.length}`,
        );

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
          sleep_stage: sleepStages,
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

  // 월별 수면 리포트가 존재하는 날짜 조회 (UTC 기준)
  async getReportDaysInMonth(
    userId: number,
    year: number,
    month: number,
  ): Promise<number[]> {
    // UTC 기준으로 월 범위 구하기
    const start = new Date(Date.UTC(year, month - 1, 1)); // 월 시작일(1일) 00:00:00
    const end = new Date(Date.UTC(year, month, 0, 23, 59, 59, 999)); // 월 마지막 날 23:59:59.999

    const reports = await this.reportRepo.find({
      where: {
        userId,
        isValidReport: true,
        sleepDate: Between(start, end),
      },
    });

    // UTC 기준 날짜만 추출
    const dateList = reports.map((r) => {
      const sleepDate = new Date(r.sleepDate);
      return sleepDate.getUTCDate();
    });

    return [...new Set(dateList)].sort((a, b) => a - b);
  }
}
