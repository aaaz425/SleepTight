import { ApiProperty } from '@nestjs/swagger';
import { SleepSoundClipResponseDto } from './sleep-sound-clip.response.dto';

export class SleepSoundAnalysisResponseDto {
  @ApiProperty()
  reportId: number;

  @ApiProperty({ type: [SleepSoundClipResponseDto] })
  sounds: SleepSoundClipResponseDto[];
}
