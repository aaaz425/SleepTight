import {
  IsArray,
  IsEnum,
  IsNumber,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { SleepStageType } from '../entities/sleep-stage-type.enum';

export class SleepStageDto {
  @IsEnum(SleepStageType)
  stageType: SleepStageType;

  @IsString()
  startTime: string;

  @IsString()
  endTime: string;
}

export class UploadSleepStagesDto {
  @IsNumber()
  reportId: number;

  @IsString()
  sleepEndTime: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SleepStageDto)
  stages: SleepStageDto[];
}
