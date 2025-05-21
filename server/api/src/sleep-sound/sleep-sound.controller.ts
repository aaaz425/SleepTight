import {
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
  Body,
  InternalServerErrorException,
  Logger,
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
@Controller('sleep-sound')
export class SleepSoundController {
  private readonly logger = new Logger(SleepSoundController.name);

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
    this.logger.log(
      `수면 음원 업로드 요청 - reportId: ${body.reportId}, fileName: ${file?.originalname}`,
    );

    try {
      const result = await this.sleepSoundService.handleUpload(file, body);
      this.logger.log(
        `수면 음원 업로드 성공 - reportId: ${body.reportId}, segmentId: ${result.segmentId}`,
      );
      return result;
    } catch (error) {
      this.logger.error(
        `수면 음원 업로드 실패 - reportId: ${body.reportId}`,
        error.stack,
      );
      throwInternalServerError(ExceptionCode.INTERNAL_SERVER_ERROR);
    }
  }
}
