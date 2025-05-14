import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SleepDiary } from './entities/sleep-diary.entity';
import { SleepReport } from './entities/sleep-report.entity';
import { CreateSleepDiaryDto } from './dto/create-sleep-diary.dto';
import { UpdateSleepDiaryDto } from './dto/update-sleep-diary.dto';

@Injectable()
export class SleepDiariesService {
  constructor(
    @InjectRepository(SleepDiary)
    private readonly diaryRepo: Repository<SleepDiary>,
    @InjectRepository(SleepReport)
    private readonly reportRepo: Repository<SleepReport>,
  ) {}

  /** 해당 리포트에 이미 일지가 있으면 중복 에러 */
  private async ensureNotExists(reportId: number) {
    const exist = await this.diaryRepo.findOne({
      where: { sleepReportId: reportId },
    });
    if (exist) {
      throw new ConflictException(
        `Diary for report ${reportId} already exists`,
      );
    }
  }

  /** 일지 생성 */
  async create(userId: number, dto: CreateSleepDiaryDto): Promise<SleepDiary> {
    // 1) 클라이언트가 넘겨준 reportId로 소유 여부 확인
    const report = await this.reportRepo.findOne({
      where: { id: dto.sleepReportId, userId },
    });
    if (!report) {
      throw new NotFoundException(`SleepReport ${dto.sleepReportId} not found`);
    }

    // 2) 날짜 중복 체크
    await this.ensureNotExists(dto.sleepReportId);

    // 3) 일지 생성
    const { sleepReportId, ...rest } = dto;
    const diary = this.diaryRepo.create({ sleepReportId, ...rest });
    return this.diaryRepo.save(diary);
  }

  /** 리포트 ID로 일지 조회 */
  async findByReportId(userId: number, reportId: number): Promise<SleepDiary> {
    const report = await this.reportRepo.findOne({
      where: { id: reportId, userId },
    });
    if (!report) {
      throw new NotFoundException(`No SleepReport for reportId ${reportId}`);
    }

    const diary = await this.diaryRepo.findOne({
      where: { sleepReportId: reportId },
    });
    if (!diary) {
      throw new NotFoundException(`Diary not found for reportId ${reportId}`);
    }
    return diary;
  }

  /** 일지 수정 */
  async update(userId: number, dto: UpdateSleepDiaryDto): Promise<SleepDiary> {
    // 1) report 확인
    const report = await this.reportRepo.findOne({
      where: { id: dto.sleepReportId, userId },
    });
    if (!report) {
      throw new NotFoundException(`No SleepReport for id ${dto.sleepReportId}`);
    }

    // 2) 일지 존재 확인
    const diary = await this.diaryRepo.findOne({
      where: { sleepReportId: dto.sleepReportId },
    });
    if (!diary) {
      throw new NotFoundException(
        `Diary not found for reportId ${dto.sleepReportId}`,
      );
    }

    // 3) 수정할 필드 덮어쓰기
    Object.assign(diary, dto);
    return this.diaryRepo.save(diary);
  }
}
