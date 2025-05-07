import { Inject, Injectable } from '@nestjs/common';
import { ClientProxy } from '@nestjs/microservices';

@Injectable()
export class SleepSoundProducer {
  constructor(
    @Inject('RABBITMQ_SERVICE') private readonly client: ClientProxy,
  ) {}

  // RabbitMQ에 메타데이터 발행
  async publishSegmentMetadata(data: {
    segmentId: string;
    s3Key: string;
    timestamp: string;
    duration: number;
    codec: string;
  }) {
    await this.client.emit('sleep.segment.metadata', data).toPromise();
  }
}
