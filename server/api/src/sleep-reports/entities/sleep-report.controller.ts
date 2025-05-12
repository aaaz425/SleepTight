import { Body, Controller, Post } from '@nestjs/common';
import { UploadSleepStagesDto } from 'src/sleep/dto/upload-sleep-stage.request.dto';
import { SleepReportService } from './sleep-report.service';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('Sleep')
@Controller('sleep')
export class SleepReportController {
  constructor(private readonly sleepReportService: SleepReportService) {}

  @Post('end-sleep')
  async uploadSleepStages(@Body() dto: UploadSleepStagesDto): Promise<{}> {
    await this.sleepReportService.uploadSleepData(dto);
    return {};
  }
}
