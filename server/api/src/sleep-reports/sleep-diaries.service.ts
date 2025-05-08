import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
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

  /** 지정일자에 이미 일지가 있으면 중복 에러 */
  private async ensureNotExists(reportId: number, date: string) {
    const exist = await this.diaryRepo.findOne({
      where: { sleepReportId: reportId, sleepDate: date },
    });
    if (exist) {
      throw new ConflictException(`Diary for ${date} already exists`);
    }
  }

  /** 오늘 또는 지정일자의 sleep_report 를 가져옴 */
  private async findReport(userId: number, date: string): Promise<SleepReport> {
    const report = await this.reportRepo.findOne({
      where: { userId, sleepDate: date },
    });
    if (!report) {
      throw new NotFoundException(`No SleepReport for date ${date}`);
    }
    return report;
  }

  /** 일지 생성 */
  async create(userId: number, dto: CreateSleepDiaryDto): Promise<SleepDiary> {
    const report = await this.findReport(userId, dto.sleepDate);
    await this.ensureNotExists(report.id, dto.sleepDate);

    const diary = this.diaryRepo.create({
      sleepReportId: report.id,
      ...dto,
    });
    return this.diaryRepo.save(diary);
  }

  /** 날짜별 일지 조회 */
  async findByDate(userId: number, date: string): Promise<SleepDiary> {
    const report = await this.findReport(userId, date);
    const diary = await this.diaryRepo.findOne({
      where: { sleepReportId: report.id, sleepDate: date },
    });
    if (!diary) {
      throw new NotFoundException(`Diary not found for date ${date}`);
    }
    return diary;
  }

  /** 날짜별 일지 수정 */
  async update(userId: number, dto: UpdateSleepDiaryDto & { sleepDate: string }): Promise<SleepDiary> {
    const report = await this.findReport(userId, dto.sleepDate);
    const diary = await this.diaryRepo.findOne({
      where: { sleepReportId: report.id, sleepDate: dto.sleepDate },
    });
    if (!diary) {
      throw new NotFoundException(`Diary not found for date ${dto.sleepDate}`);
    }

    Object.assign(diary, dto);
    return this.diaryRepo.save(diary);
  }
}
