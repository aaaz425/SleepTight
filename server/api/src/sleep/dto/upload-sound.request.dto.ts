import { IsNumber, IsISO8601, IsBase64, IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UploadSoundRequestDto {
  @ApiProperty({ example: 1, description: '수면 리포트 ID' })
  @IsNumber()
  reportId: number;

  @ApiProperty({
    example: 'a15b89ab-278e-4a57-b7db-d8f6e14c5e60',
    description: '수면 음성 세그먼트 UUID',
  })
  @IsUUID()
  segmentId: string;

  @ApiProperty({
    example: '2025-05-01T02:30:00Z',
    description: '녹음 시작 시간 (ISO 8601 형식)',
  })
  @IsISO8601()
  timestamp: string;

  @ApiProperty({ example: 10, description: '녹음 길이(초)' })
  @IsNumber()
  duration: number;

  @ApiProperty({
    example: 'SGVsbG8=',
    description: 'base64 인코딩된 오디오 데이터',
  })
  @IsBase64()
  base64Data: string;
}
