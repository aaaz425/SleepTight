import {
  Body,
  Controller,
  Get,
  Logger,
  Param,
  Post,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { SleepCoachingService } from './sleep-coaching.service';
import { SleepCoachingResponseDto } from './dto/sleep-coaching.response.dto';
import { ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { createSleepCoachingDto } from './dto/create-sleep-coaching.request.dto';
import { TempResponseDto } from './dto/temp.response.dto';

@Controller('sleep-coaching')
export class SleepCoachingController {
  private readonly logger = new Logger(SleepCoachingController.name);
  constructor(private readonly sleepCoachingService: SleepCoachingService) {}

  @ApiOperation({ summary: '수면 코칭 조회' })
  @ApiBearerAuth() // JWT 인증 필요
  @Get(':coaching_date')
  @UseGuards(JwtAuthGuard)
  async getSleepCoaching(@Request() req, @Param('coaching_date') date: Date) {
    const userId: number = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(`수면 코칭 조회 요청 - userId: ${userId}, date: ${date}`);
    try {
      // const dtoList: SleepCoachingResponseDto[] = await this.sleepCoachingService.getSleepCoaching(userId, date)
      const dtoList: any = new TempResponseDto().temp;
      this.logger.log(`수면 코칭 조회 성공 - userId: ${userId}, date: ${date}`);
      return dtoList;
    } catch (error) {
      this.logger.error(
        `수면 코칭 조회 실패 - userId: ${userId}, date: ${date}`,
        error.stack,
      );
      throw error;
    }
  }

  @ApiOperation({ summary: '수면 코칭 생성' })
  @ApiBearerAuth() // JWT 인증 필요
  @Post()
  @UseGuards(JwtAuthGuard)
  async createSleepCoaching(
    @Request() req,
    @Body() requestDto: createSleepCoachingDto,
  ): Promise<any> {
    const userId: number = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(
      `수면 코칭 생성 요청 - userId: ${userId}, sleepReportId: ${requestDto.sleepReportId}`,
    );

    //비동기로 바로 리턴
    this.sleepCoachingService
      .createSleepCoaching(userId, requestDto.sleepReportId)
      .then(() => {
        this.logger.log(
          `수면 코칭 생성 완료 - userId: ${userId}, sleepReportId: ${requestDto.sleepReportId}`,
        );
      })
      .catch((err) => {
        this.logger.error(
          `수면 코칭 생성 실패 - userId: ${userId}, sleepReportId: ${requestDto.sleepReportId}`,
          err.stack,
        );
      });

    return 'sleep-coaching is processing';
  }
}
