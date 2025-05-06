import { Injectable } from '@nestjs/common';
import { AmqpConnection } from '@golevelup/nestjs-rabbitmq';

@Injectable()
export class SleepSoundProducer {
  constructor(private readonly amqpConnection: AmqpConnection) {}

  // RabbitMQ에 메타데이터 발행
  async publishSegmentMetadata(data: {
    segmentId: string;
    s3Key: string;
    timestamp: string;
    duration: number;
    codec: string;
  }) {
    await this.amqpConnection.publish('audio.segment', '', data);
  }
}
