import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UploadSleepSoundRequestDto } from './dto/upload-sleep-sound.request.dto';
import { UploadSleepSoundResponseDto } from './dto/upload-sleep-sound.response.dto';
import { SleepSoundService } from './sleep-sound.service';
import { ApiConsumes, ApiTags } from '@nestjs/swagger';
import { Express } from 'express';
import { DataSource } from 'typeorm';

@ApiTags('Sleep')
@Controller('sleep/sound')
export class SleepSoundController {
  constructor(
    private readonly sleepSoundService: SleepSoundService,
    private readonly dataSource: DataSource,
  ) {}

  @Post()
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: {
        fileSize: 10 * 1024 * 1024, // 10MB로 업로드 파일 용량 제한
      },
    }),
  )
  async uploadSleepSound(
    @UploadedFile() file: Express.Multer.File,
    @Body() body: UploadSleepSoundRequestDto,
  ): Promise<UploadSleepSoundResponseDto> {
    return this.sleepSoundService.handleUpload(file, body);
  }
}
