import { Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ClientProxy } from '@nestjs/microservices';

@Injectable()
export class SleepSoundProducer {
  constructor(
    @Inject('RABBITMQ_SERVICE') private readonly client: ClientProxy,
    private readonly cofigService :ConfigService,  
  ) {} 

  // RabbitMQ에 메타데이터 발행
  async publishSegmentMetadata(data: {
    segmentId: string;
    s3Key: string;
    timestamp: string;
    duration: number;
    codec: string;
  }) {
    // 라우팅 키 'segment.meta'
    const routeKey = this.cofigService.get<string>('RMQ_SEND_ROUTING_KEY');
    await this.client.emit(routeKey, data).toPromise();
  }
}
