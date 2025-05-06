import { ConfigService } from '@nestjs/config';
import { SleepSoundFactory } from './sleep-sound.factory';
import { forwardRef, Inject, Injectable } from '@nestjs/common';
import { UploadSleepSoundRequestDto } from './dto/upload-sleep-sound.request.dto';
import { UploadSleepSoundResponseDto } from './dto/upload-sleep-sound.response.dto';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { VoiceType } from './entities/voice-type.enum';
import { SleepSoundProducer } from './sleep-sound.producer';

@Injectable()
export class SleepSoundService {
  constructor(
    @Inject('S3_CLIENT') private readonly s3: S3Client,
    private readonly configService: ConfigService,
    private readonly sleepSoundFactory: SleepSoundFactory,
    @Inject(forwardRef(() => SleepSoundProducer))
    private readonly sleepSoundProducer: SleepSoundProducer,
  ) {}

  async handleUpload(
    file: Express.Multer.File,
    body: UploadSleepSoundRequestDto,
  ): Promise<UploadSleepSoundResponseDto> {
    const { segmentId, reportId, duration, timestamp } = body;

    const key = `audio-prod/${segmentId}.opus`;

    const bucket = this.configService.get<string>('AWS_S3_BUCKET')!;
    const region = this.configService.get<string>('AWS_S3_REGION')!;

    // S3에 파일 업로드
    await this.s3.send(
      new PutObjectCommand({
        Bucket: bucket,
        Key: key,
        Body: file.buffer,
        ContentType: file.mimetype,
      }),
    );

    const fileUrl = `https://${bucket}.s3.${region}.amazonaws.com/${key}`;

    // DB에 음성 메타데이터 저장 (기본값: BREATH)
    const sleepSound = this.sleepSoundFactory.create({
      reportId,
      segmentId,
      fileUrl,
      duration,
      voiceType: VoiceType.BREATH,
    });
    await this.sleepSoundFactory.save(sleepSound);

    // RabbitMQ에 메타데이터 발행 요청
    await this.sleepSoundProducer.publishSegmentMetadata({
      segmentId,
      s3Key: key,
      timestamp,
      duration,
      codec: 'opus',
    });

    return {
      success: true,
      data: {
        segmentId,
        fileUrl,
      },
    };
  }
}
