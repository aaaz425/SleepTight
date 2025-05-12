import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { SleepReport } from './sleep-report.entity';
import { SleepStageService } from 'src/sleep/sleep-stage.service';
import { UploadSleepStagesDto } from 'src/sleep/dto/upload-sleep-stage.request.dto';

@Injectable()
export class SleepReportService {
  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(SleepReport)
    private readonly reportRepo: Repository<SleepReport>,
    private readonly sleepStageService: SleepStageService,
  ) {}

  async uploadSleepData(dto: UploadSleepStagesDto): Promise<void> {
    const report = await this.reportRepo.findOneByOrFail({ id: dto.reportId });

    await this.dataSource.transaction(async (manager) => {
      // 종료 시간 계산
      const sleepEndTime = this.parseTime(
        dto.sleepEndTime,
        report.sleepStartTime,
      );
      report.sleepEndTime = sleepEndTime;
      await manager.save(report);

      // 수면 단계 저장을 sleep 도메인에 위임
      await this.sleepStageService.saveStages(dto.stages, report.id, manager);
    });
  }

  private parseTime(timeStr: string, baseDate: Date): Date {
    const [hour, minute] = timeStr.split(':').map(Number);
    const result = new Date(baseDate);
    result.setHours(hour, minute, 0, 0);
    if (result < baseDate) result.setDate(result.getDate() + 1);
    return result;
  }
}
