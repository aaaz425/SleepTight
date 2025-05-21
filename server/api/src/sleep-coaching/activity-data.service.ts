import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { LessThanOrEqual, Repository } from 'typeorm';
import { ActivityData } from './entities/activity-data.entity';
import { SleepReport } from 'src/sleep-reports/entities/sleep-report.entity';
import { UploadActivityDataRequestDto } from './dto/upload-activity-data.request.dto';
import { throwNotFoundException } from 'src/common/exceptions/exception.helper';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';

@Injectable()
export class ActivityDataService {
  private readonly logger = new Logger(ActivityDataService.name);

  constructor(
    @InjectRepository(ActivityData)
    private readonly activityRepo: Repository<ActivityData>,

    @InjectRepository(SleepReport)
    private readonly sleepReportRepo: Repository<SleepReport>,
  ) {}

  async saveActivityData(
    userId: number,
    dto: UploadActivityDataRequestDto,
  ): Promise<void> {
    this.logger.log(
      `활동 데이터 저장 시작 - userId: ${userId}, records: ${dto.records.length}`,
    );
    try {
      // 가장 최근의 유효 수면 리포트 찾기
      this.logger.debug(
        `최근 수면 리포트 조회 - userId: ${userId}, endTime: ${dto.endTime}`,
      );
      const sleepReport = await this.sleepReportRepo.findOne({
        where: {
          userId,
          isValidReport: true,
          sleepEndTime: LessThanOrEqual(new Date(dto.endTime)),
        },
        order: {
          sleepEndTime: 'DESC',
        },
      });

      if (!sleepReport) {
        this.logger.warn(
          `수면 리포트 없음 - userId: ${userId}, endTime: ${dto.endTime}`,
        );
        throw throwNotFoundException(ExceptionCode.REPORT_NOT_FOUND);
      }

      const sleepDate = sleepReport.sleepDate;
      this.logger.debug(
        `수면 리포트 찾음 - reportId: ${sleepReport.id}, sleepDate: ${sleepDate}`,
      );

      let savedCount = 0;
      let skippedCount = 0;

      for (const record of dto.records) {
        this.logger.debug(
          `활동 데이터 처리 - userId: ${userId}, dataType: ${record.dataType}`,
        );

        const exists = await this.activityRepo.findOne({
          where: {
            userId,
            dataType: record.dataType,
            reportDate: sleepDate,
          },
        });

        if (exists) {
          this.logger.debug(
            `이미 존재하는 활동 데이터 - userId: ${userId}, dataType: ${record.dataType}, reportDate: ${sleepDate}`,
          );
          skippedCount++;
          continue;
        }

        const entity = this.activityRepo.create({
          userId,
          dataType: record.dataType,
          valueNumber: Number(record.value),
          unit: record.unit,
          activityStartTime: new Date(dto.startTime),
          activityEndTime: new Date(dto.endTime),
          reportDate: sleepDate,
        });

        await this.activityRepo.save(entity);
        savedCount++;
      }

      this.logger.log(
        `활동 데이터 저장 완료 - userId: ${userId}, 저장: ${savedCount}, 건너뜀: ${skippedCount}`,
      );
    } catch (error) {
      this.logger.error(
        `활동 데이터 저장 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }
}
