import { ApiProperty } from '@nestjs/swagger';
import { IsISO8601 } from 'class-validator';

export class StartSleepRequestDto {
  @ApiProperty({
    example: '2025-05-13T04:23:12Z',
    description: '수면 시작 시간 (ISO 8601 형식)',
  })
  @IsISO8601()
  sleep_start_time: string;
}
