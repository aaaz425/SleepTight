import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { LessThanOrEqual, Repository } from 'typeorm';
import { ActivityData } from './entities/activity-data.entity';
import { SleepReport } from 'src/sleep-reports/entities/sleep-report.entity';
import { UploadActivityDataRequestDto } from './dto/upload-activity-data.request.dto';
import { throwNotFoundException } from 'src/common/exceptions/exception.helper';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';

@Injectable()
export class ActivityDataService {
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
    // 가장 최근의 유효 수면 리포트 찾기
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
      throw throwNotFoundException(ExceptionCode.REPORT_NOT_FOUND);
    }

    const sleepDate = sleepReport.sleepDate;

    for (const record of dto.records) {
      const exists = await this.activityRepo.findOne({
        where: {
          userId,
          dataType: record.dataType,
          reportDate: sleepDate,
        },
      });

      if (exists) continue;

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
    }
  }
}
