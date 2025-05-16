import {
  Body,
  Controller,
  Post,
  UseGuards,
  Request,
  Get,
  Param,
} from '@nestjs/common';
import { EndSleepRequestDto } from 'src/sleep-reports/dto/end-sleep.request.dto';
import { SleepReportService } from './sleep-report.service';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiOkResponse,
} from '@nestjs/swagger';
import { StartSleepRequestDto } from './dto/start-sleep.request.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { StartSleepResponseDto } from './dto/start-sleep.response.dto';
import { EndSleepResponseDto } from './dto/end-sleep.response.dto';
import { SleepReportResponseDto } from './dto/sleep-report.response.dto';

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
}
