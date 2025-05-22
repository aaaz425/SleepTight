// src/sleep-diaries/dto/sleep-diary.response.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { WakeAwareness, WakeMethod } from '../entities/sleep-diary.entity';

export class SleepDiaryResponseDto {
  @ApiProperty()
  id: number;

  @ApiProperty({ description: '연결된 리포트 ID' })
  sleepReportId: number;

  @ApiProperty({ description: '수면 일자 (YYYY-MM-DD)' })
  sleepDate: string;

  @ApiProperty({ description: '수면 시작 시간 (HH:MM:SS)' })
  sleepTime: string;

  @ApiProperty({ description: '기상 시간 (HH:MM:SS)' })
  wakeTime: string;

  @ApiProperty({ description: '잠드는 데 걸린 시간 (interval 문자열)' })
  sleepLatency: any;

  @ApiProperty({ description: '깬 횟수' })
  wakeCount: number;

  @ApiProperty({ description: '수면 품질 점수 (1–7)', nullable: true })
  sleepQuality: number | null;

  @ApiProperty({ description: '기상 시 기분 점수 (1–7)', nullable: true })
  moodScore: number | null;

  @ApiProperty({ enum: WakeAwareness, nullable: true })
  wakeAwareness: WakeAwareness | null;

  @ApiProperty({ enum: WakeMethod, nullable: true })
  wakeMethod: WakeMethod | null;

  @ApiProperty({
    description: '기타 기상 방법',
    required: false,
    nullable: true,
  })
  wakeMethodEtc?: string | null;
}
