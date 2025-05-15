import { Body, Controller, Post, UseGuards, Request } from '@nestjs/common';
import { EndSleepRequestDto } from 'src/sleep-reports/dto/end-sleep.request.dto';
import { SleepReportService } from './sleep-report.service';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { StartSleepRequestDto } from './dto/start-sleep.request.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { StartSleepResponseDto } from './dto/start-sleep.response.dto';
import { EndSleepResponseDto } from './dto/end-sleep.response.dto';

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
}
