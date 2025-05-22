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

/**
 * 수면 단계 DTO
 * 주의 (백엔드 개발자용):
 * 1. 클라이언트에서 서버로 전송할 때는 KST 기준의 시간을 받아서 UTC로 변환 후 저장합니다.
 * 2. 서버에서 클라이언트로 응답할 때는 모든 시간이 UTC로 전송됩니다.
 * 3. 응답 형식은 기존 형식을 유지하여 프론트엔드 코드 수정이 필요 없도록 합니다.
 */
export class SleepStageDto {
  @ApiProperty({ enum: SleepStageType, description: '수면 단계 유형' })
  @IsEnum(SleepStageType)
  stageType: SleepStageType;

  @ApiProperty({
    example: '2025-05-13T13:23:12Z',
    description: '수면 단계 시작 시간 (ISO 8601 형식)',
  })
  @IsString()
  startTime: string;

  @ApiProperty({
    example: '2025-05-13T14:00:00Z',
    description: '수면 단계 종료 시간 (ISO 8601 형식)',
  })
  @IsString()
  endTime: string;
}

/**
 * 전체 수면 종료 요청 DTO
 * 모든 시간 응답은 UTC 기준으로 반환됩니다.
 */
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
