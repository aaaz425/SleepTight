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
  import { CreateSleepDiaryDto } from './dto/create-sleep-diary.dto';
  import { UpdateSleepDiaryDto } from './dto/update-sleep-diary.dto';
  
  @Controller('api/sleep-reports/diaries')
  @UseGuards(JwtAuthGuard)
  export class SleepDiariesController {
    constructor(private readonly diariesService: SleepDiariesService) {}
  
    /** 일지 작성 (오늘 날짜 또는 dto.sleepDate 기준) */
    @Post()
    create(
      @Req() req,
      @Body() dto: CreateSleepDiaryDto,
    ) {
      const userId = req.user.userId;
      return this.diariesService.create(userId, dto);
    }
  
    /** 특정일자 일지 조회 */
    @Get(':date')
    findByDate(
      @Req() req,
      @Param('date') date: string,   // "YYYY-MM-DD"
    ) {
      const userId = req.user.userId;
      return this.diariesService.findByDate(userId, date);
    }
  
    /** 일지 수정 */
    @Patch()
    update(
      @Req() req,
      @Body() dto: UpdateSleepDiaryDto & { sleepDate: string },
    ) {
      const userId = req.user.userId;
      return this.diariesService.update(userId, dto);
    }
  }
  