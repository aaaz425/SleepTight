import { Module } from '@nestjs/common';
import { RabbitMQModule } from '@golevelup/nestjs-rabbitmq';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    ConfigModule,
    RabbitMQModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        uri: `amqp://${config.get('RABBITMQ_DEFAULT_USER')}:${config.get('RABBITMQ_DEFAULT_PASS')}@${config.get('RABBITMQ_HOST')}:${config.get('RABBITMQ_PORT')}`,
        exchanges: [{ name: 'audio.segment', type: 'direct' }],
      }),
    }),
  ],
  exports: [RabbitMQModule],
})
export class RabbitMQMessagingModule {}
