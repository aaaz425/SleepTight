import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Req,
  UseGuards,
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
  constructor(private readonly diariesService: SleepDiariesService) {}

  /** 특정 리포트 일지 조회 */
  @Get(':reportId')
  async findByReportId(
    @Req() req,
    @Param('reportId') reportId: string,
  ): Promise<SleepDiaryResponseDto> {
    const userId = req.user.userId;
    return this.diariesService.findByReportId(userId, +reportId);
  }

  /** 일지 수정 */
  @Patch()
  update(@Req() req, @Body() dto: UpdateSleepDiaryDto) {
    const userId = req.user.userId;
    return this.diariesService.update(userId, dto);
  }

  /** 특정 일자 일지 목록 조회*/
  @Get('date/:date')
  async findByDate(
    @Req() req,
    @Param('date') date: string,
  ): Promise<(SleepDiaryResponseDto | null)[]> {
    const userId = req.user.userId;
    return this.diariesService.findByDate(userId, date);
  }
}
