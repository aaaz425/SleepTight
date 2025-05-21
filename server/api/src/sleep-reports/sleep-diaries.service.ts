import {
  BadRequestException,
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { SleepDiary, WakeMethod } from './entities/sleep-diary.entity';
import { SleepReport } from './entities/sleep-report.entity';
import { UpdateSleepDiaryDto } from './dto/update-sleep-diary.request.dto';
import { SleepDiaryResponseDto } from './dto/sleep-diary.response.dto';
import { throwNotFoundException } from 'src/common/exceptions/exception.helper';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';

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
  async createPartialFromReport(report: SleepReport): Promise<SleepDiary> {
    const exist = await this.diaryRepo.findOne({
      where: { sleepReportId: report.id },
    });
    if (exist) {
      return exist; // 이미 있으면 생성 안 함
    }

    // 수면 날짜가 문자열이면 그대로 사용, Date 객체면 UTC 기준으로 변환
    let sleepDate: string;
    if (typeof report.sleepDate === 'string') {
      sleepDate = report.sleepDate;
    } else {
      // UTC 기준 날짜 문자열로 변환
      sleepDate = report.sleepDate.toISOString().split('T')[0];
    }

    // 시간은 항상 UTC 기준으로 처리
    const sleepTime = report.sleepStartTime
      .toISOString()
      .split('T')[1]
      .split('.')[0]; // HH:MM:SS in UTC
    const wakeTime = report.sleepEndTime
      ?.toISOString()
      .split('T')[1]
      .split('.')[0]; // HH:MM:SS in UTC

    const diary = this.diaryRepo.create({
      sleepReportId: report.id,
      sleepDate: sleepDate,
      sleepTime: sleepTime,
      wakeTime: wakeTime,
      sleepLatency: report.sleepLatency,
      wakeCount: report.awakenCount,
    });

    return this.diaryRepo.save(diary);
  }

  /** 수면 일지 수정
   * 1. 유저 입장에서 처음 수면 일지 작성 시
   * 2. 수면 일지 수정 시
   */
  async update(userId: number, dto: UpdateSleepDiaryDto): Promise<SleepDiary> {
    // 1) report 확인
    const report = await this.reportRepo.findOne({
      where: { id: dto.sleepReportId, userId },
    });
    if (!report) {
      throwNotFoundException(ExceptionCode.REPORT_NOT_FOUND);
    }

    // 2) 일지 존재 확인
    const diary = await this.diaryRepo.findOne({
      where: { sleepReportId: dto.sleepReportId },
    });
    if (!diary) {
      throwNotFoundException(ExceptionCode.DIARY_NOT_FOUND);
    }

    // 3) 수정할 필드 덮어쓰기

    if (dto.wakeMethod !== WakeMethod.OTHER) {
      dto.wakeMethodEtc = null;
    }
    Object.assign(diary, dto);
    return this.diaryRepo.save(diary);
  }

  /** 리포트 ID로 일지 조회 */
  async findByReportId(
    userId: number,
    reportId: number,
  ): Promise<SleepDiaryResponseDto> {
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
    return this.toResponseDto(diary);
  }

  /**
   * 날짜별 다이어리 조회(리포트 기준)
   *  날짜로 보고서 목록을 먼저 조회한 뒤,
   *  각 보고서별 일지가 있으면 가져오고, 없으면 null 로 채워 반환
   *  @param userId
   *  @param date  YYYY-MM-DD 형식의 문자열
   */
  async findByDate(
    userId: number,
    date: string,
  ): Promise<(SleepDiaryResponseDto | null)[]> {
    // 1) date 포맷 검증
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      throw new BadRequestException('date는 YYYY-MM-DD 형식이어야 합니다.');
    }

    const dateComponents = date.split('-').map(Number);

    // 2) UTC 기준으로 날짜 구하기 (날짜만 정확히 일치시키기 위해)
    const formattedDate = new Date(
      Date.UTC(dateComponents[0], dateComponents[1] - 1, dateComponents[2]),
    )
      .toISOString()
      .split('T')[0];

    // 3) 정확히 해당 날짜의 리포트만 조회
    const reports = await this.reportRepo
      .createQueryBuilder('report')
      .select('report.id')
      .where('report.user_id = :userId', { userId })
      .andWhere('report.is_valid_report = :isValid', { isValid: true })
      .andWhere('report.sleep_date = :date', { date: formattedDate })
      .orderBy('report.sleep_end_time', 'DESC')
      .getMany();

    if (reports.length === 0) {
      return [];
    }

    // 4) diary 조회 및 매핑
    const reportIds = reports.map((r) => r.id);
    const diaries = await this.diaryRepo.find({
      where: { sleepReportId: In(reportIds) },
      order: { id: 'DESC' },
    });
    const diaryMap = new Map<number, SleepDiary>();
    for (const d of diaries) {
      if (!diaryMap.has(d.sleepReportId)) diaryMap.set(d.sleepReportId, d);
    }

    // 5) 순서대로 DTO 나열 (없으면 null)
    return reports.map((r) => {
      const ent = diaryMap.get(r.id);
      return ent ? this.toResponseDto(ent) : null;
    });
  }

  /** 엔티티 → DTO 변환 헬퍼 */
  private toResponseDto(entity: SleepDiary): SleepDiaryResponseDto {
    const dto = new SleepDiaryResponseDto();
    dto.id = entity.id;
    dto.sleepReportId = entity.sleepReportId;
    dto.sleepDate = entity.sleepDate;
    dto.sleepTime = entity.sleepTime;
    dto.wakeTime = entity.wakeTime;
    dto.sleepLatency = entity.sleepLatency;

    // nullable 필드 → null 병합 연산자 추가
    dto.wakeCount = entity.wakeCount ?? null;
    dto.sleepQuality = entity.sleepQuality ?? null;
    dto.moodScore = entity.moodScore ?? null;
    dto.wakeAwareness = entity.wakeAwareness ?? null;
    dto.wakeMethod = entity.wakeMethod ?? null;
    dto.wakeMethodEtc = entity.wakeMethodEtc ?? null;

    return dto;
  }
}
