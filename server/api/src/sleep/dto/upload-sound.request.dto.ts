import {
  IsString,
  IsNumber,
  IsISO8601,
  IsBase64,
  IsUUID,
} from 'class-validator';

export class UploadSoundRequestDto {
  @IsNumber()
  reportId: number;

  @IsUUID()
  segmentId: string;

  @IsISO8601()
  timestamp: string;

  @IsNumber()
  duration: number;

  @IsBase64()
  base64Data: string;
}
