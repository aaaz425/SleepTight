import {
  IsArray,
  IsEnum,
  IsNumber,
  IsOptional,
  IsDateString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ActivityDataType } from '../entities/activity-data.enum';
import { ActivityUnit } from '../entities/activity-unit.enum';
import { ApiProperty } from '@nestjs/swagger';

// request의 records 부분
export class ActivityRecordDto {
  @ApiProperty({ example: 'WATER', description: '활동 데이터 종류' })
  @IsEnum(ActivityDataType)
  dataType: ActivityDataType;

  @ApiProperty({ example: 1, description: '활동 수치 (숫자)' })
  @IsNumber()
  value: number;

  @ApiProperty({ example: 'LITER', description: '단위', required: false })
  @IsOptional()
  @IsEnum(ActivityUnit)
  unit?: ActivityUnit;
}

// request 전체 바디 형식
export class UploadActivityDataRequestDto {
  @ApiProperty({
    example: '2025-05-12T08:00:00Z',
    description: '데이터 수집 시작 시간 (UTC ISO 8601)',
  })
  @IsDateString()
  startTime: string;

  @ApiProperty({
    example: '2025-05-13T08:00:00Z',
    description: '데이터 수집 종료 시간 (수면 종료 시간)',
  })
  @IsDateString()
  endTime: string;

  @ApiProperty({
    type: [ActivityRecordDto],
    description: '활동 데이터 리스트',
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ActivityRecordDto)
  records: ActivityRecordDto[];
}
