import { ApiProperty } from '@nestjs/swagger';
import { SleepStageResponseDto } from './sleep-stage.response.dto';

export class SleepReportResponseDto {
  @ApiProperty()
  sleepReportId: number;

  @ApiProperty()
  sleepStartTime: string;

  @ApiProperty()
  sleepEndTime: string;

  @ApiProperty()
  sleepLatency: string;

  @ApiProperty()
  totalAwakeTime: string;

  @ApiProperty()
  totalRemSleepTime: string;

  @ApiProperty()
  totalLightSleepTime: string;

  @ApiProperty()
  totalDeepSleepTime: string;

  @ApiProperty()
  awakenCount: number;

  @ApiProperty({ type: [SleepStageResponseDto] })
  sleepStages: SleepStageResponseDto[];
}
