import { ApiProperty } from '@nestjs/swagger';

export class SleepEventResponseDto {
  @ApiProperty()
  eventId: number;

  @ApiProperty()
  anomaly: string;

  @ApiProperty()
  eventStartSec: number;

  @ApiProperty()
  eventEndSec: number;

  @ApiProperty()
  confidence: number;
}
