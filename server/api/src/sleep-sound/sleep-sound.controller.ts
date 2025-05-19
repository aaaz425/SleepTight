import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
  InternalServerErrorException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UploadSleepSoundRequestDto } from './dto/upload-sleep-sound.request.dto';
import { UploadSleepSoundResponseDto } from './dto/upload-sleep-sound.response.dto';
import { SleepSoundService } from './sleep-sound.service';
import { ApiBearerAuth, ApiConsumes, ApiTags } from '@nestjs/swagger';
import { Express } from 'express';
import { DataSource } from 'typeorm';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';
import { throwInternalServerError } from 'src/common/exceptions/exception.helper';

@ApiBearerAuth()
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
    console.log('🔔 [SleepSoundController] 업로드 요청:', body);
    try {
      const result = await this.sleepSoundService.handleUpload(file, body);
      console.log('✅ [SleepSoundController] 업로드 성공:', result);
      return result;
    } catch (error) {
      console.error('❌ [SleepSoundController] 업로드 실패:', error);
      throwInternalServerError(ExceptionCode.INTERNAL_SERVER_ERROR);
    }
  }
}
