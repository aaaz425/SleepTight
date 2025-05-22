import { Module } from '@nestjs/common';
import { SleepSoundController } from './sleep-sound.controller';
import { SleepSoundService } from './sleep-sound.service';
import { SleepSound } from './entities/sleep-sound.entity';
import { S3Module } from 'src/common/aws/s3.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SleepSoundFactory } from './sleep-sound.factory';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { SleepSoundProducer } from './sleep-sound.producer';
import { ClientsModule, Transport } from '@nestjs/microservices';
import { SleepStageService } from '../sleep-reports/sleep-stage.service';
import { SleepStageFactory } from '../sleep-reports/sleep-stage.factory';
import { SleepStageLog } from '../sleep-reports/entities/sleep-stage-log.entity';
import { SleepEvent } from './entities/sleep-event.entity';
import { SleepAnalysisResultListener } from './sleep-analysis-result.listener';

@Module({
  imports: [
    TypeOrmModule.forFeature([SleepSound, SleepEvent, SleepStageLog]),
    S3Module,
    ConfigModule,
    ClientsModule.registerAsync([
      {
        name: 'RABBITMQ_SERVICE',
        imports: [ConfigModule],
        inject: [ConfigService],
        useFactory: (config: ConfigService) => ({
          transport: Transport.RMQ,
          options: {
            urls: [
              `amqp://${config.get('RABBITMQ_DEFAULT_USER')}:${config.get('RABBITMQ_DEFAULT_PASS')}@${config.get('RABBITMQ_HOST')}:${config.get('RABBITMQ_PORT')}`,
            ],
            queue: config.get<string>('RMQ_SEND_QUEUE'),
            exchange: config.get<string>('RMQ_SEND_EXCHANGE'),
            queueOptions: { durable: false },
          },
        }),
      },
    ]),
  ],
  controllers: [SleepSoundController, SleepAnalysisResultListener],
  providers: [SleepSoundProducer, SleepSoundService, SleepSoundFactory],
  exports: [SleepSoundService],
})
export class SleepSoundModule {}
