import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UploadSoundRequestDto } from './dto/upload-sound.request.dto';
import { UploadSoundResponseDto } from './dto/upload-sound.response.dto';
import { SoundService } from './sound.service';
import { ApiConsumes, ApiTags } from '@nestjs/swagger';
import { Express } from 'express';

@ApiTags('Sleep')
@Controller('sleep/sound')
export class SoundController {
  constructor(private readonly soundService: SoundService) {}

  @Post()
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: {
        fileSize: 10 * 1024 * 1024, // 10MB로 업로드 파일 용량 제한
      },
    }),
  )
  async uploadSound(
    @UploadedFile() file: Express.Multer.File,
    @Body() body: UploadSoundRequestDto,
  ): Promise<UploadSoundResponseDto> {
    return this.soundService.handleUpload(file, body);
  }
}
