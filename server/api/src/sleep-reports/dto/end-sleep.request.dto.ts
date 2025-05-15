import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsEnum,
  IsNumber,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { SleepStageType } from '../entities/sleep-stage-type.enum';

// 수면 단계 DTO
export class SleepStageDto {
  @ApiProperty({ enum: SleepStageType, description: '수면 단계 유형' })
  @IsEnum(SleepStageType)
  stageType: SleepStageType;

  @ApiProperty({
    example: '2025-05-13T04:23:12Z',
    description: '수면 단계 시작 시간 (ISO 8601 형식)',
  })
  @IsString()
  startTime: string;

  @ApiProperty({
    example: '2025-05-13T05:00:00Z',
    description: '수면 단계 종료 시간 (ISO 8601 형식)',
  })
  @IsString()
  endTime: string;
}

// 전체 수면 종료 요청 DTO
export class EndSleepRequestDto {
  @ApiProperty({ example: 25, description: '수면 리포트 ID' })
  @IsNumber()
  reportId: number;

  @ApiProperty({
    example: '2025-05-13T08:00:00Z',
    description: '수면 종료 시간 (ISO 8601 형식)',
  })
  @IsString()
  sleepEndTime: string;

  @ApiProperty({
    type: [SleepStageDto],
    description: '수면 단계 배열',
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SleepStageDto)
  stages: SleepStageDto[];
}
