import { ApiProperty } from '@nestjs/swagger';

export class UploadSleepSoundResponseDto {
  @ApiProperty({ example: true })
  success: boolean;

  @ApiProperty({
    example: {
      segmentId: 'a15b89ab-278e-4a57-b7db-d8f6e14c5e60',
      fileUrl: 'https://sleep-sound/example.opus',
    },
  })
  data: {
    segmentId: string;
    fileUrl: string;
  };
}
