import { Controller, Get, Request, UseGuards } from "@nestjs/common";
import { JwtAuthGuard } from "src/auth/jwt-auth.guard";
import { SleepReportService } from "src/sleep-reports/sleep-report.service";

@Controller("sleep-coaching")
export class SleepCoachingService {
  constructor(
    private readonly sleepReportService: SleepReportService,
  ) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  async getSleepCoaching(@Request() req, date: Date) {
    const userId: number = req.user.userId; // JWT에서 userId를 가져옴
    // return this.sleepReportService.getSleepCoaching(userId, date);
  }
}