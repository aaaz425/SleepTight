import { Body, Controller, Get, Post, Request, UseGuards } from "@nestjs/common";
import { JwtAuthGuard } from "src/auth/jwt-auth.guard";
import { SleepCoachingService } from "./sleep-coaching.service";

@Controller("sleep-coaching")
export class SleepCoachingController {
  constructor(
    private readonly sleepCoachingService: SleepCoachingService,
  ) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  async getSleepCoaching(@Request() req, @Body("sleepReportId") sleepReportId: number) :Promise<any>{
    const userId: number = req.user.userId; // JWT에서 userId를 가져옴
    const response = await this.sleepCoachingService.getSleepCoaching(userId, sleepReportId);
    return response;
  }
}