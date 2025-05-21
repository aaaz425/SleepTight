import {
  Body,
  Controller,
  Post,
  UseGuards,
  Request,
  Get,
  Param,
  Query,
  BadRequestException,
  ParseIntPipe,
  Logger,
} from '@nestjs/common';
import { EndSleepRequestDto } from 'src/sleep-reports/dto/end-sleep.request.dto';
import { SleepReportService } from './sleep-report.service';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiOkResponse,
  ApiQuery,
} from '@nestjs/swagger';
import { StartSleepRequestDto } from './dto/start-sleep.request.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { StartSleepResponseDto } from './dto/start-sleep.response.dto';
import { EndSleepResponseDto } from './dto/end-sleep.response.dto';
import { SleepReportResponseDto } from './dto/sleep-report.response.dto';
import { SleepSoundAnalysisResponseDto } from './dto/sleep-sound-analysis.response.dto';
import { SleepReportCalendarResponseDto } from './dto/get-sleep-report-calendar.response.dto';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';

@ApiTags('Sleep Report')
@Controller('sleep-report')
export class SleepReportController {
  private readonly logger = new Logger(SleepReportController.name);

  constructor(private readonly sleepReportService: SleepReportService) {}

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('start-sleep')
  @ApiOperation({ summary: '수면 시작' })
  async startSleep(
    @Request() req,
    @Body() dto: StartSleepRequestDto,
  ): Promise<StartSleepResponseDto> {
    const userId = req.user.userId;
    this.logger.log(`수면 시작 요청 - userId: ${userId}`);

    try {
      const reportId = await this.sleepReportService.startSleep(userId, dto);
      this.logger.log(
        `수면 시작 성공 - userId: ${userId}, reportId: ${reportId}`,
      );
      return { reportId };
    } catch (error) {
      this.logger.error(`수면 시작 실패 - userId: ${userId}`, error.stack);
      throw error;
    }
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('end-sleep')
  @ApiOperation({ summary: '수면 종료' })
  async endSleep(
    @Body() dto: EndSleepRequestDto,
  ): Promise<EndSleepResponseDto> {
    this.logger.log(`수면 종료 요청 - reportId: ${dto.reportId}`);

    try {
      const isValidReport = await this.sleepReportService.endSleep(dto);
      this.logger.log(
        `수면 종료 성공 - reportId: ${dto.reportId}, isValidReport: ${isValidReport}`,
      );
      return { isValidReport };
    } catch (error) {
      this.logger.error(
        `수면 종료 실패 - reportId: ${dto.reportId}`,
        error.stack,
      );
      throw error;
    }
  }

  // NOTE: 아래의 calendar 라우트를 먼저 선언해야 ':date'에 calendar가 걸리지 않음
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Get('calendar')
  @ApiOperation({ summary: '월별 수면 리포트가 존재하는 날짜 목록' })
  @ApiQuery({ name: 'year', required: true, example: 2025 })
  @ApiQuery({ name: 'month', required: true, example: 5 })
  @ApiOkResponse({ type: SleepReportCalendarResponseDto })
  async getCalendarMarkedDays(
    @Request() req,
    @Query('year', ParseIntPipe) year: number,
    @Query('month', ParseIntPipe) month: number,
  ): Promise<SleepReportCalendarResponseDto> {
    const userId = req.user.userId;
    this.logger.log(
      `월별 수면 리포트 날짜 목록 요청 - userId: ${userId}, year: ${year}, month: ${month}`,
    );

    try {
      // 유효성 검사 (1~12월)
      if (
        !Number.isInteger(year) ||
        !Number.isInteger(month) ||
        month < 1 ||
        month > 12
      ) {
        this.logger.warn(
          `유효하지 않은 날짜 형식 - year: ${year}, month: ${month}`,
        );
        throw new BadRequestException(ExceptionCode.INVALID_DATE_FORMAT);
      }

      // 조회
      const dateList = await this.sleepReportService.getReportDaysInMonth(
        userId,
        year,
        month,
      );
      this.logger.log(
        `월별 수면 리포트 날짜 목록 조회 성공 - userId: ${userId}, 날짜 수: ${dateList.length}`,
      );
      return { date: dateList };
    } catch (error) {
      this.logger.error(
        `월별 수면 리포트 날짜 목록 조회 실패 - userId: ${userId}, year: ${year}, month: ${month}`,
        error.stack,
      );
      throw error;
    }
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Get(':date')
  @ApiOperation({ summary: '해당 일자의 수면 리포트 조회' })
  @ApiOkResponse({
    description: '해당 일자의 리포트 목록',
    type: [SleepReportResponseDto],
  })
  async getReportsByDate(@Request() req, @Param('date') date: string) {
    const userId = req.user.userId;
    this.logger.log(
      `일자별 수면 리포트 조회 요청 - userId: ${userId}, date: ${date}`,
    );

    try {
      // 날짜 형식 검증
      if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
        this.logger.warn(`유효하지 않은 날짜 형식 - date: ${date}`);
        throw new BadRequestException(ExceptionCode.INVALID_DATE_FORMAT);
      }

      const reportList =
        await this.sleepReportService.getReportsByDateWithStages(userId, date);

      this.logger.log(
        `일자별 수면 리포트 조회 성공 - userId: ${userId}, date: ${date}, 리포트 수: ${reportList.length}`,
      );

      // 기존 응답 형식 유지 (필드 추가 없이)
      return reportList.map((report) => ({
        ...report,
        sleep_start_time: report.sleep_start_time.toISOString(),
        sleep_end_time: report.sleep_end_time?.toISOString(),
        sleep_stage: report.sleep_stage.map((stage) => ({
          ...stage,
          startTime: stage.startTime.toISOString(),
          endTime: stage.endTime.toISOString(),
        })),
      }));
    } catch (error) {
      this.logger.error(
        `일자별 수면 리포트 조회 실패 - userId: ${userId}, date: ${date}`,
        error.stack,
      );
      throw error;
    }
  }

  @Get('events/:reportId')
  @ApiOperation({ summary: '수면 리포트 분석 결과 조회' })
  @ApiOkResponse({ type: SleepSoundAnalysisResponseDto })
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  async getSleepSoundEvents(
    @Request() req,
    @Param('reportId') reportId: number,
  ) {
    const userId = req.user.userId;
    this.logger.log(
      `수면 리포트 분석 결과 조회 요청 - userId: ${userId}, reportId: ${reportId}`,
    );

    try {
      const result =
        await this.sleepReportService.getSleepEventsByReportId(reportId);
      this.logger.log(
        `수면 리포트 분석 결과 조회 성공 - userId: ${userId}, reportId: ${reportId}`,
      );
      return result;
    } catch (error) {
      this.logger.error(
        `수면 리포트 분석 결과 조회 실패 - userId: ${userId}, reportId: ${reportId}`,
        error.stack,
      );
      throw error;
    }
  }
}
