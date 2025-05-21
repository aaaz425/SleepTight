import { Inject, Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Between, Repository } from 'typeorm';
import { ActivityData } from './entities/activity-data.entity';
import { throwNotFoundException } from 'src/common/exceptions/exception.helper';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';
import { SleepReport } from 'src/sleep-reports/entities/sleep-report.entity';
import { ActiveTime } from './interfaces/active-time.interface';
import { SleepTime } from './interfaces/sleep-time.interface';
import { SleepDiary } from 'src/sleep-reports/entities/sleep-diary.entity';
import axios from 'axios';
import { SleepCoaching } from './entities/sleep-coaching.entity';
import { SleepCoachingResponseDto } from './dto/sleep-coaching.response.dto';
import { FcmService } from 'src/common/fcm/fcm.service';

@Injectable()
export class SleepCoachingService {
  private readonly logger = new Logger(SleepCoachingService.name);

  constructor(
    @InjectRepository(ActivityData)
    private readonly activityDataRepository: Repository<ActivityData>,
    @InjectRepository(SleepReport)
    private readonly sleepReportRepository: Repository<SleepReport>,
    @InjectRepository(SleepDiary)
    private readonly sleepDiaryRepository: Repository<SleepDiary>,
    @InjectRepository(SleepCoaching)
    private readonly sleepCoachingRepository: Repository<SleepCoaching>,
    private fcmService: FcmService,
  ) {}

  async getSleepCoaching(
    userId: number,
    date: Date,
  ): Promise<SleepCoachingResponseDto[]> {
    this.logger.log(`수면 코칭 조회 시작 - userId: ${userId}, date: ${date}`);
    try {
      const sleepCoachings: SleepCoaching[] =
        await this.sleepCoachingRepository.findBy({
          userId: userId,
          sleepCoachingDate: date,
        });

      //오늘 수면 코칭이 생성되지 않은 경우, 예외 발생
      //추후 화면에 따라 바로 생성되도록 할 수 있음
      if (!sleepCoachings || sleepCoachings.length === 0) {
        this.logger.warn(
          `수면 코칭 데이터 없음 - userId: ${userId}, date: ${date}`,
        );
        throwNotFoundException(ExceptionCode.SlEEP_COACHING_NOT_FOUND);
      }

      const dtoList: SleepCoachingResponseDto[] = sleepCoachings.map((entity) =>
        SleepCoachingResponseDto.fromEntity(entity),
      );

      this.logger.log(
        `수면 코칭 조회 성공 - userId: ${userId}, date: ${date}, count: ${dtoList.length}`,
      );
      return dtoList;
    } catch (error) {
      this.logger.error(
        `수면 코칭 조회 실패 - userId: ${userId}, date: ${date}`,
        error.stack,
      );
      throw error;
    }
  }

  async createSleepCoaching(
    userId: number,
    sleepReportId: number,
  ): Promise<any> {
    this.logger.log(
      `수면 코칭 생성 시작 - userId: ${userId}, sleepReportId: ${sleepReportId}`,
    );
    try {
      const sleepReport: SleepReport | null =
        await this.sleepReportRepository.findOneBy({ id: sleepReportId });
      if (!sleepReport) {
        this.logger.warn(`수면 보고서 없음 - sleepReportId: ${sleepReportId}`);
        throwNotFoundException(ExceptionCode.REPORT_NOT_FOUND);
      }

      //수면 종료시간 기준, 이전 24시간 활동데이터를 바탕으로 분석 요청
      const baseTime = sleepReport.sleepEndTime;
      const startTime = new Date(baseTime.getTime() - 24 * 60 * 60 * 1000);
      this.logger.debug(`활동 데이터 조회 기간: ${startTime} ~ ${baseTime}`);

      //현재시간에서 24시간 동안의 활동데이터를 가져옵니다.
      const activityDataList = await this.activityDataRepository.find({
        where: {
          userId: userId,
          activityEndTime: Between(startTime, baseTime),
        },
      });

      //활동데이터가 없는경우 예외처리
      if (!activityDataList || activityDataList.length === 0) {
        this.logger.warn(
          `활동 데이터 없음 - userId: ${userId}, 기간: ${startTime} ~ ${baseTime}`,
        );
        throwNotFoundException(ExceptionCode.ACTIVITY_DATA_NOT_FOUND);
      }

      this.logger.log(
        `활동 데이터 조회 성공 - userId: ${userId}, 데이터 수: ${activityDataList.length}`,
      );

      //fastAPI서버에 요청을 보내는 로직
      const activeTime: ActiveTime[] = activityDataList.map((activityData) => ({
        dataType: activityData.dataType,
        value: activityData.valueNumber,
        unit: activityData.unit,
      }));

      const sleepTime: SleepTime[] =
        await this.settingSleepTimeData(sleepReport);
      this.logger.debug(
        `AI 서버에 코칭 요청 - userId: ${userId}, sleepReportId: ${sleepReportId}`,
      );

      const response = await axios.post('http://sleep-tight-ai:8081/coaching', {
        weekly_data: activeTime,
        night_data: sleepTime,
      });

      this.logger.debug(`AI 서버 응답 성공 - status: ${response.status}`);
      const coachings = response.data.activity_list;

      //데이터 코칭 엔티티로 변환
      const sleepCoachingEntities: SleepCoaching[] = coachings.map((coaching) =>
        SleepCoaching.responseToSleepCoaching(userId, sleepReportId, coaching),
      );

      //코칭 엔티티 테이블에 저장
      this.logger.debug(
        `수면 코칭 데이터 저장 시작 - 개수: ${sleepCoachingEntities.length}`,
      );
      await Promise.all(
        sleepCoachingEntities.map((entity) =>
          this.sleepCoachingRepository.save(entity),
        ),
      );
      this.logger.log(
        `수면 코칭 데이터 저장 완료 - userId: ${userId}, sleepReportId: ${sleepReportId}`,
      );

      //fcm알림
      this.logger.debug(`FCM 알림 전송 시작 - userId: ${userId}`);
      await this.fcmService.sendNotification(
        userId,
        '수면 코칭 생성 완료!',
        '수면 코칭 생성이 완료되었습니다!',
      );
      this.logger.log(
        `수면 코칭 생성 완료 - userId: ${userId}, sleepReportId: ${sleepReportId}`,
      );

      return;
    } catch (error) {
      this.logger.error(
        `수면 코칭 생성 실패 - userId: ${userId}, sleepReportId: ${sleepReportId}`,
        error.stack,
      );
      throw error;
    }
  }

  private async settingSleepTimeData(sleepReport: SleepReport): Promise<any> {
    this.logger.debug(
      `수면 시간 데이터 설정 시작 - sleepReportId: ${sleepReport.id}`,
    );
    try {
      const lightSleep = {
        dataType: 'LIGHT',
        value: this.intervalToMinutes(sleepReport.totalLightSleepTime),
        unit: 'MINUTE',
      };

      const deepSleep = {
        dataType: 'DEEP',
        value: this.intervalToMinutes(sleepReport.totalDeepSleepTime),
        unit: 'MINUTE',
      };

      const remSleep = {
        dataType: 'REM',
        value: this.intervalToMinutes(sleepReport.totalRemSleepTime),
        unit: 'MINUTE',
      };

      const awake = {
        dataType: 'AWAKE',
        value: this.intervalToMinutes(sleepReport.totalAwakeTime),
        unit: 'MINUTE',
      };

      const sleepDiary = await this.sleepDiaryRepository.findOne({
        where: { sleepReportId: 1 },
      });
      const sleepScore = {
        dataType: 'SLEEP_SCORE',
        value: sleepDiary?.sleepQuality,
        unit: 'SCORE',
      };
      const sleepTime: SleepTime[] = [
        lightSleep,
        deepSleep,
        remSleep,
        awake,
        sleepScore,
      ];

      this.logger.debug(
        `수면 시간 데이터 설정 완료 - sleepReportId: ${sleepReport.id}`,
      );
      return sleepTime;
    } catch (error) {
      this.logger.error(
        `수면 시간 데이터 설정 실패 - sleepReportId: ${sleepReport.id}`,
        error.stack,
      );
      throw error;
    }
  }

  private intervalToMinutes(interval: any) {
    const hours = interval.hours || 0;
    const minutes = interval.minutes || 0;
    const seconds = interval.seconds || 0;
    const totalMinutes = hours * 60 + minutes + Math.floor(seconds / 60);
    return totalMinutes;
  }
}
