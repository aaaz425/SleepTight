import { Controller, Post, Body } from '@nestjs/common';
import { UploadSoundRequestDto } from './dto/upload-sound.request.dto';
import { UploadSoundResponseDto } from './dto/upload-sound.response.dto';
import { SoundService } from './sound.service';
import { ApiTags } from '@nestjs/swagger';

@ApiTags('Sleep')
@Controller('api/sleep/sound')
export class SoundController {
  constructor(private readonly soundService: SoundService) {}

  @Post()
  async uploadSound(
    @Body() body: UploadSoundRequestDto,
  ): Promise<UploadSoundResponseDto> {
    return this.soundService.handleUpload(body);
  }
}
