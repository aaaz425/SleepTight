import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Req,
  UseGuards,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { SleepDiariesService } from './sleep-diaries.service';
import { UpdateSleepDiaryDto } from './dto/update-sleep-diary.request.dto';
import { SleepDiaryResponseDto } from './dto/sleep-diary.response.dto';
import { ApiBearerAuth } from '@nestjs/swagger';

@Controller('sleep-reports/diaries') // ← 전역 /api prefix를 쓰므로 여기서는 api/ 생략
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SleepDiariesController {
  private readonly logger = new Logger(SleepDiariesController.name);

  constructor(private readonly diariesService: SleepDiariesService) {}

  /** 특정 일자 일지 목록 조회 - 구체적인 경로가 먼저 오도록 순서 변경 */
  @Get('date/:date')
  async findByDate(
    @Req() req,
    @Param('date') date: string,
  ): Promise<(SleepDiaryResponseDto | null)[]> {
    const userId = req.user.userId;
    this.logger.log(
      `수면 일지 일자별 조회 요청 - userId: ${userId}, date: ${date}`,
    );

    try {
      // 날짜 형식 검증
      if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
        this.logger.warn(`유효하지 않은 날짜 형식 - date: ${date}`);
        throw new BadRequestException('date는 YYYY-MM-DD 형식이어야 합니다.');
      }

      const diaries = await this.diariesService.findByDate(userId, date);
      this.logger.log(
        `수면 일지 일자별 조회 성공 - userId: ${userId}, date: ${date}, 일지 수: ${diaries.length}`,
      );

      // 기존 응답 형식 유지
      return diaries;
    } catch (error) {
      this.logger.error(
        `수면 일지 일자별 조회 실패 - userId: ${userId}, date: ${date}`,
        error.stack,
      );
      throw error;
    }
  }

  /** 특정 리포트 일지 조회 */
  @Get(':reportId')
  async findByReportId(
    @Req() req,
    @Param('reportId') reportId: string,
  ): Promise<SleepDiaryResponseDto> {
    const userId = req.user.userId;
    this.logger.log(
      `수면 일지 리포트별 조회 요청 - userId: ${userId}, reportId: ${reportId}`,
    );

    try {
      const diary = await this.diariesService.findByReportId(userId, +reportId);
      this.logger.log(
        `수면 일지 리포트별 조회 성공 - userId: ${userId}, reportId: ${reportId}`,
      );
      return diary;
    } catch (error) {
      this.logger.error(
        `수면 일지 리포트별 조회 실패 - userId: ${userId}, reportId: ${reportId}`,
        error.stack,
      );
      throw error;
    }
  }

  /** 일지 수정 */
  @Patch()
  async update(@Req() req, @Body() dto: UpdateSleepDiaryDto) {
    const userId = req.user.userId;
    this.logger.log(
      `수면 일지 수정 요청 - userId: ${userId}, sleepReportId: ${dto.sleepReportId}`,
    );

    try {
      const result = await this.diariesService.update(userId, dto);
      this.logger.log(
        `수면 일지 수정 성공 - userId: ${userId}, sleepReportId: ${dto.sleepReportId}`,
      );
      return result;
    } catch (error) {
      this.logger.error(
        `수면 일지 수정 실패 - userId: ${userId}, sleepReportId: ${dto.sleepReportId}`,
        error.stack,
      );
      throw error;
    }
  }
}
