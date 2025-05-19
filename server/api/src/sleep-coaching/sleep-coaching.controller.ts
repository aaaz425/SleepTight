import { Body, Controller, Get, Post, Request, UseGuards } from "@nestjs/common";
import { JwtAuthGuard } from "src/auth/jwt-auth.guard";
import { SleepCoachingService } from "./sleep-coaching.service";
import { SleepCoachingResponseDto } from "./dto/sleep-coaching.response.dto";
import { ApiBearerAuth, ApiOperation } from "@nestjs/swagger";

@Controller("sleep-coaching")
export class SleepCoachingController {
  constructor(
    private readonly sleepCoachingService: SleepCoachingService,
  ) {}

  @ApiOperation({ summary: '수면 코칭 조회' })
  @ApiBearerAuth() // JWT 인증 필요
  @Get()
  @UseGuards(JwtAuthGuard)
  async getSleepCoaching(@Request() req, @Body('coaching_date') date :Date) {
    const userId: number = req.user.userId; // JWT에서 userId를 가져옴
    const dtoList: SleepCoachingResponseDto[] = await this.sleepCoachingService.getSleepCoaching(userId, date) 
    return dtoList;
  }

  @ApiOperation({ summary: '수면 코칭 생성' })
  @ApiBearerAuth() // JWT 인증 필요
  @Post()
  @UseGuards(JwtAuthGuard)
  async createSleepCoaching(@Request() req, @Body("sleepReportId") sleepReportId: number) :Promise<any>{
    const userId: number = req.user.userId; // JWT에서 userId를 가져옴
    await this.sleepCoachingService.createSleepCoaching(userId, sleepReportId);
    return "sleep-coaching is processing";
  }

}