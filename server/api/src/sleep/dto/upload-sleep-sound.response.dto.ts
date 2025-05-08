import { ApiProperty } from '@nestjs/swagger';

export class UploadSleepSoundResponseDto {
  @ApiProperty({ example: 'a15b89ab-278e-4a57-b7db-d8f6e14c5e60' })
  segmentId: string;

  @ApiProperty({ example: 'https://sleep-sound/example.opus' })
  fileUrl: string;

  static from(params: {
    segmentId: string;
    fileUrl: string;
  }): UploadSleepSoundResponseDto {
    const dto = new UploadSleepSoundResponseDto();
    dto.segmentId = params.segmentId;
    dto.fileUrl = params.fileUrl;
    return dto;
  }
}
