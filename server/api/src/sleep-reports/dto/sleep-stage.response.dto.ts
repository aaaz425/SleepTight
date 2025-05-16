import { ApiProperty } from '@nestjs/swagger';
import { SleepStageType } from '../entities/sleep-stage-type.enum';

export class SleepStageResponseDto {
  @ApiProperty({ enum: SleepStageType })
  stageType: SleepStageType;

  @ApiProperty({ example: '2025-05-16T01:30:00.000Z' })
  startTime: string;

  @ApiProperty({ example: '2025-05-16T01:40:00.000Z' })
  endTime: string;

  @ApiProperty({ example: 10, description: '단계 지속 시간 (분)' })
  duration: number;
}
