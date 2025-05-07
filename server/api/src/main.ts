import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { setupSwagger } from './common/config/swagger';
import { setupGlobalPrefix } from './common/config/prefix';
import { ValidationPipe } from '@nestjs/common';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { ConfigService } from '@nestjs/config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);

  const uri = `amqp://${configService.get('RABBITMQ_DEFAULT_USER')}:${configService.get('RABBITMQ_DEFAULT_PASS')}@${configService.get('RABBITMQ_HOST')}:${configService.get('RABBITMQ_PORT')}`;
  const queue = configService.get('RABBITMQ_QUEUE');

  // 수신 처리 시 주석 해제
  // // MQ 마이크로서비스 연결
  // app.connectMicroservice<MicroserviceOptions>({
  //   transport: Transport.RMQ,
  //   options: {
  //     urls: [uri],
  //     queue,
  //     queueOptions: { durable: false },
  //   },
  // });

  // await app.startAllMicroservices();

  app.useGlobalPipes(new ValidationPipe());

  setupSwagger(app);
  setupGlobalPrefix(app);

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
