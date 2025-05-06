import { Module } from '@nestjs/common';
import { SleepSoundController } from './sleep-sound.controller';
import { SleepSoundService } from './sleep-sound.service';
import { SleepSound } from './entities/sleep-sound.entity';
import { S3Module } from 'src/common/aws/s3.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SleepSoundFactory } from './sleep-sound.factory';
import { ConfigModule } from '@nestjs/config';
import { RabbitMQModule } from '@golevelup/nestjs-rabbitmq';
import { SleepSoundProducer } from './sleep-sound.producer';

@Module({
  imports: [
    TypeOrmModule.forFeature([SleepSound]),
    S3Module,
    ConfigModule,
    RabbitMQModule,
  ],
  controllers: [SleepSoundController],
  providers: [SleepSoundProducer, SleepSoundService, SleepSoundFactory],
})
export class SleepSoundModule {}
