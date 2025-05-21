import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';
import { ConfigService } from '@nestjs/config';
import { SleepSoundFactory } from './sleep-sound.factory';
import { forwardRef, Inject, Injectable, Logger } from '@nestjs/common';
import { UploadSleepSoundRequestDto } from './dto/upload-sleep-sound.request.dto';
import { UploadSleepSoundResponseDto } from './dto/upload-sleep-sound.response.dto';
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
} from '@aws-sdk/client-s3';
import { SleepSoundProducer } from './sleep-sound.producer';
import { throwBadRequest } from 'src/common/exceptions/exception.helper';
import { SleepEvent } from './entities/sleep-event.entity';
import { AnomalyType } from './entities/anomaly-type.enum';
import { EntityManager } from 'typeorm';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { SleepSoundAnalysisResponseDto } from 'src/sleep-reports/dto/sleep-sound-analysis.response.dto';
import { SleepSound } from './entities/sleep-sound.entity';

const dayjs = require('dayjs');
const utc = require('dayjs/plugin/utc');
dayjs.extend(utc);

@Injectable()
export class SleepSoundService {
  private readonly logger = new Logger(SleepSoundService.name);

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

    const exists = await this.sleepSoundFactory.exist({
      where: { segmentId },
    });
    if (exists) {
      throwBadRequest(ExceptionCode.DUPLICATE_SEGMENT_ID);
    }

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
    const startTime = new Date(timestamp);

    // DB에 음성 메타데이터 저장
    const sleepSound = this.sleepSoundFactory.create({
      reportId,
      segmentId,
      fileUrl,
      duration,
      startTime,
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
    return UploadSleepSoundResponseDto.from({ segmentId, fileUrl });
  }

  async saveSleepEvent(sleepEvent: SleepEvent) {
    this.sleepSoundFactory.saveSleepEvent(sleepEvent);
    this.logger.log(
      `✅ 수면 이벤트 저장 완료 - segmentId: ${sleepEvent.segmentId}, anomaly: ${sleepEvent.anomaly}, 구간: ${sleepEvent.startSec}s ~ ${sleepEvent.endSec}s`,
    );
  }

  async calculateEventDurations(
    reportId: number,
    manager: EntityManager,
  ): Promise<{
    snoring: number;
    somniloquy: number;
    coughing: number;
  }> {
    // 해당 리포트에 연결된 segmentId들 조회
    const sounds =
      await this.sleepSoundFactory.findByReportIdWithQueryBuilder(reportId);
    this.logger.debug(`📌 [calculateEventDurations] reportId: ${reportId}`);

    const segmentIds = sounds.map((sound) => sound.segmentId);
    if (!segmentIds.length) return { snoring: 0, somniloquy: 0, coughing: 0 };

    // segmentId에 해당하는 이벤트들 조회
    const events = await this.sleepSoundFactory.findEventsBySegmentIds(
      segmentIds,
      manager,
    );
    console.log('🧪 segmentIds:', segmentIds);
    console.log('🧪 loaded events:', events);

    // anomaly 기준으로 누적 시간 계산
    let snoring = 0;
    let somniloquy = 0;
    let coughing = 0;

    for (const event of events) {
      const duration = event.endSec - event.startSec;
      switch (event.anomaly) {
        case AnomalyType.SNORE:
          snoring += duration;
          break;
        case AnomalyType.SOMNILOQUY:
          somniloquy += duration;
          break;
        case AnomalyType.COUGH:
          coughing += duration;
          break;
      }
    }

    return {
      snoring: Math.round(snoring),
      somniloquy: Math.round(somniloquy),
      coughing: Math.round(coughing),
    };
  }

  // Presigned URL 만들기
  async getPresignedUrl(key: string): Promise<string> {
    const command = new GetObjectCommand({
      Bucket: this.configService.get('AWS_S3_BUCKET'),
      Key: key,
    });

    const url = await getSignedUrl(this.s3, command, { expiresIn: 60 }); // 60초 유효
    return url;
  }
  calculateTotalDurationsFromSounds(sounds: SleepSound[]): {
    snoring: number;
    somniloquy: number;
    coughing: number;
  } {
    let snoring = 0,
      somniloquy = 0,
      coughing = 0;

    for (const sound of sounds) {
      for (const event of sound.events ?? []) {
        const duration = event.endSec - event.startSec;
        if (event.anomaly === 'SNORE') snoring += duration;
        else if (event.anomaly === 'SOMNILOQUY') somniloquy += duration;
        else if (event.anomaly === 'COUGH') coughing += duration;
      }
    }

    return {
      snoring: Math.round(snoring),
      somniloquy: Math.round(somniloquy),
      coughing: Math.round(coughing),
    };
  }
  // 수면 분석 결과 조회
  async getSleepEventsByReportId(
    reportId: number,
    manager?: EntityManager,
  ): Promise<SleepSoundAnalysisResponseDto> {
    const sounds =
      await this.sleepSoundFactory.findWithEventsByReportId(reportId);
    this.logger.debug('📌 loaded sounds:', sounds);

    //수면 음성이 없는 경우 빈배열로 리턴
    if (!sounds || sounds.length===0) {
      return {reportId, sounds: []};
    }

    const result = await Promise.all(
      sounds.map(async (sound: any) => {
        const soundStart = dayjs(sound.startTime);
        const soundEnd = soundStart.add(sound.duration, 'seconds');

        const presignedUrl = await this.getPresignedUrl(
          `audio-prod/${sound.segmentId}.opus`,
        );

        return {
          soundId: sound.id,
          soundStartTime: soundStart.utc().format('HH:mm:ss'),
          soundEndTime: soundEnd.utc().format('HH:mm:ss'),
          clipUrl: presignedUrl,
          events: (sound.events ?? []).map((e) => ({
            eventId: e.id,
            anomaly: e.anomaly,
            eventStartSec: e.startSec,
            eventEndSec: e.endSec,
            confidence: e.confidence,
          })),
        };
      }),
    );

    return {
      reportId,
      sounds: result,
    };
  }
}
