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
    const reportId = await this.sleepReportService.startSleep(userId, dto);
    return { reportId };
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('end-sleep')
  @ApiOperation({ summary: '수면 종료' })
  async endSleep(
    @Body() dto: EndSleepRequestDto,
  ): Promise<EndSleepResponseDto> {
    const isValidReport = await this.sleepReportService.endSleep(dto);
    return { isValidReport };
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
    console.log('📆 Query Params:', { year, month });
    console.log('📆 isInteger check:', {
      yearValid: Number.isInteger(year),
      monthValid: Number.isInteger(month),
    });

    // 유효성 검사 (1~12월)
    if (
      !Number.isInteger(year) ||
      !Number.isInteger(month) ||
      month < 1 ||
      month > 12
    ) {
      throw new BadRequestException(ExceptionCode.INVALID_DATE_FORMAT);
    }

    // 조회
    const userId = req.user.userId;
    const dateList = await this.sleepReportService.getReportDaysInMonth(
      userId,
      year,
      month,
    );
    return { date: dateList };
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
    const reportList = await this.sleepReportService.getReportsByDateWithStages(
      userId,
      date,
    );
    return reportList;
  }

  @Get('events/:reportId')
  @ApiOperation({ summary: '수면 리포트 분석 결과 조회' })
  @ApiOkResponse({ type: SleepSoundAnalysisResponseDto })
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  async getSleepSoundEvents(@Param('reportId') reportId: number) {
    return this.sleepReportService.getSleepEventsByReportId(reportId);
  }
}
