import { ApiProperty } from '@nestjs/swagger';
import { SleepEventResponseDto } from './sleep-event.response.dto';

export class SleepSoundClipResponseDto {
  @ApiProperty()
  soundId: number;

  @ApiProperty()
  soundStartTime: string;

  @ApiProperty()
  soundEndTime: string;

  @ApiProperty()
  clipUrl: string;

  @ApiProperty({ type: [SleepEventResponseDto] })
  events: SleepEventResponseDto[];
}
