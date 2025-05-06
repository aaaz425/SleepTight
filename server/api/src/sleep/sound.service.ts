import { ConfigService } from '@nestjs/config';
import { SleepSoundFactory } from './sleep-sound.factory';
import { Inject, Injectable } from '@nestjs/common';
import { UploadSoundRequestDto } from './dto/upload-sound.request.dto';
import { UploadSoundResponseDto } from './dto/upload-sound.response.dto';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { VoiceType } from './entities/voice-type.enum';

@Injectable()
export class SoundService {
  constructor(
    @Inject('S3_CLIENT') private readonly s3: S3Client,
    private readonly configService: ConfigService,
    private readonly SleepSoundFactory: SleepSoundFactory,
  ) {}

  async handleUpload(
    file: Express.Multer.File,
    body: UploadSoundRequestDto,
  ): Promise<UploadSoundResponseDto> {
    const { segmentId, reportId, duration } = body;

    const key = `audio-prod/${segmentId}.opus`;

    const bucket = this.configService.get<string>('AWS_S3_BUCKET')!;
    const region = this.configService.get<string>('AWS_S3_REGION')!;

    await this.s3.send(
      new PutObjectCommand({
        Bucket: bucket,
        Key: key,
        Body: file.buffer,
        ContentType: file.mimetype,
      }),
    );

    const fileUrl = `https://${bucket}.s3.${region}.amazonaws.com/${key}`; //버킷 이름 확인 필요

    const sleepSound = this.SleepSoundFactory.create({
      reportId,
      segmentId,
      fileUrl,
      duration,
      voiceType: VoiceType.BREATH, // 분석 전이므로 숨소리를 기본값으로 저장
    });

    await this.SleepSoundFactory.save(sleepSound);

    return {
      success: true,
      data: {
        segmentId,
        fileUrl,
      },
    };
  }
}
