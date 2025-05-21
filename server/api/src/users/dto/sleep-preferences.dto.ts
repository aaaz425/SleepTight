import { IsOptional, IsString } from 'class-validator';

export class SleepPreferencesDto {
  @IsString()
  targetSleepTime: string; // "HH:MM" 형식

  @IsString()
  targetWakeTime: string; // "HH:MM" 형식

  @IsOptional()
  @IsString()
  timezone: string = 'Asia/Seoul'; // 기본값
} 