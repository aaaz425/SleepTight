import { IsNumber, IsISO8601, IsUUID, IsOptional } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class UploadSoundRequestDto {
  @ApiProperty({ type: 'string', format: 'binary' })
  @IsOptional() // 이건 실제로는 안 씀. Swagger UI용
  file?: any;

  @ApiProperty({ example: 1, description: '수면 리포트 ID' })
  @Type(() => Number)
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
  @Type(() => Number)
  @IsNumber()
  duration: number;
}
