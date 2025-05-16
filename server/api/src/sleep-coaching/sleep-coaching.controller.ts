import { Body, Controller, Get, Request, UseGuards } from "@nestjs/common";
import { JwtAuthGuard } from "src/auth/jwt-auth.guard";
import { SleepCoachingService } from "./sleep-coaching.service";

@Controller("sleep-coaching")
export class SleepCoachingController {
  constructor(
    private readonly sleepCoachingService: SleepCoachingService,
  ) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  async getSleepCoaching(@Request() req, @Body("sleepReportId") sleepReportId: number) :Promise<any>{
    const userId: number = req.user.userId; // JWT에서 userId를 가져옴
    const response = this.sleepCoachingService.getSleepCoaching(userId, sleepReportId);
    return response;
  }
}