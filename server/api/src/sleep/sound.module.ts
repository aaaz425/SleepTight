import { Module } from '@nestjs/common';
import { SoundController } from './sound.controller';
import { SoundService } from './sound.service';
import { SleepSound } from './entities/sleep-sound.entity';
import { S3Module } from 'src/common/aws/s3.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SleepSoundFactory } from './sleep-sound.factory';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [TypeOrmModule.forFeature([SleepSound]), S3Module, ConfigModule],
  controllers: [SoundController],
  providers: [SoundService, SleepSoundFactory],
})
export class SoundModule {}
