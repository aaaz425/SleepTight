import { WakeAwareness, WakeMethod } from '../entities/sleep-diary.entity';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateSleepDiaryDto {
  @ApiProperty({
    description: '수면 리포트 ID',
    example: 7,
  })
  sleepReportId: number;

  @ApiPropertyOptional({
    description: '취침 시간 (HH:MM:SS)',
    example: '23:30:00',
  })
  sleepTime?: string;

  @ApiPropertyOptional({
    description: '기상 시간 (HH:MM:SS)',
    example: '06:45:00',
  })
  wakeTime?: string;

  @ApiPropertyOptional({
    description: '자다 깬 횟수',
    example: 2,
  })
  wakeCount?: number;

  @ApiPropertyOptional({
    description: '수면의 질 점수 (1~7)',
    example: 5,
  })
  sleepQuality?: number;

  @ApiPropertyOptional({
    description: '기상 시 기분 점수 (1~7)',
    example: 4,
  })
  moodScore?: number;

  @ApiPropertyOptional({
    enum: WakeAwareness,
    description: '잠 깼을 때 인지 여부',
    example: WakeAwareness.NORMAL,
  })
  wakeAwareness?: WakeAwareness;

  @ApiPropertyOptional({
    enum: WakeMethod,
    description: '기상 방법',
    example: WakeMethod.ALARM,
  })
  wakeMethod?: WakeMethod;

  @ApiPropertyOptional({
    description: '기타 기상 방법 설명',
    example: '반려동물이 깨웠어요',
  })
  wakeMethodEtc?: string | null;
}
