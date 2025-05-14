import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { SleepReport } from './entities/sleep-report.entity';
import { SleepStageService } from 'src/sleep-reports/sleep-stage.service';
import { UploadSleepStagesDto } from 'src/sleep-reports/dto/upload-sleep-stage.request.dto';
import { StartSleepRequestDto } from './dto/start-sleep.request.dto';

@Injectable()
export class SleepReportService {
  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(SleepReport)
    private readonly reportRepo: Repository<SleepReport>,
    private readonly sleepStageService: SleepStageService,
  ) {}

  // 수면 시작
  async startSleep(userId: number, dto: StartSleepRequestDto): Promise<number> {
    // ISO 8601 문자열을 Date 객체로 변환
    const sleepStartTime = new Date(dto.sleep_start_time);

    // SleepReport 생성
    const report = this.reportRepo.create({
      userId,
      sleepStartTime,
    });

    // 저장 후 ID 반환
    const saved = await this.reportRepo.save(report);
    return saved.id;
  }

  // 수면 종료 + 수면 단계 업로드
  async uploadSleepData(dto: UploadSleepStagesDto): Promise<void> {
    const report = await this.reportRepo.findOneByOrFail({ id: dto.reportId });

    await this.dataSource.transaction(async (manager) => {
      // 종료 시간 계산
      const sleepEndTime = new Date(dto.sleepEndTime);
      report.sleepEndTime = sleepEndTime;

      report.sleepDate = new Date(sleepEndTime.toDateString());

      await manager.save(report);

      // 수면 단계 저장을 sleep 도메인에 위임
      await this.sleepStageService.saveStages(dto.stages, report.id, manager);
    });
  }
}
