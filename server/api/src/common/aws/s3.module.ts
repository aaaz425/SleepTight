import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { s3ClientFactory } from './s3.provider';

@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: 'S3_CLIENT',
      useFactory: s3ClientFactory,
      inject: [ConfigService],
    },
  ],
  exports: ['S3_CLIENT'],
})
export class S3Module {}
