import { Injectable } from '@nestjs/common';
import { UploadSoundRequestDto } from './dto/upload-sound.request.dto';
import { UploadSoundResponseDto } from './dto/upload-sound.response.dto';
import { Buffer } from 'buffer';

@Injectable()
export class SoundService {
  async handleUpload(
    body: UploadSoundRequestDto,
  ): Promise<UploadSoundResponseDto> {
    const { segmentId, base64Data } = body;

    const binaryData = Buffer.from(base64Data, 'base64');

    // 아직은 저장하지 않고 응답만 반환
    return {
      success: true,
      data: {
        segmentId,
      },
    };
  }
}
