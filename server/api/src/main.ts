import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { setupSwagger } from './common/config/swagger';
import { setupGlobalPrefix } from './common/config/prefix';
import { ValidationPipe, Logger } from '@nestjs/common';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { ConfigService } from '@nestjs/config';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';
import { collectDefaultMetrics, Registry } from 'prom-client';
import * as express from 'express';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule, {
    logger: ['error', 'warn', 'log', 'debug'],
  });
  const configService = app.get(ConfigService);

  logger.log('서버 시작 중...');

  // Prometheus 메트릭 설정
  logger.log('Prometheus 메트릭 설정 중...');
  const register = new Registry();
  collectDefaultMetrics({ register });

  // Express용 /metrics 엔드포인트 추가
  const expressApp = app.getHttpAdapter().getInstance();
  expressApp.get('/metrics', async (_req, res) => {
    res.set('Content-Type', register.contentType);
    res.send(await register.metrics());
  });
  logger.log('Prometheus 메트릭 엔드포인트 (/metrics) 설정 완료');

  // const uri = `amqp://${configService.get('RABBITMQ_DEFAULT_USER')}:${configService.get('RABBITMQ_DEFAULT_PASS')}@${configService.get('RABBITMQ_HOST')}:${configService.get('RABBITMQ_PORT')}`;
  const uri = configService.get('RMQ_REMOTE_URI');
  const queue = configService.get('RABBITMQ_QUEUE');

  // MQ 마이크로서비스 연결
  logger.log('RabbitMQ 마이크로서비스 연결 중...');
  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.RMQ,
    options: {
      urls: [uri],
      exchange: configService.get<string>('RMQ_RECV_EXCHANGE'),
      exchangeType: 'direct',
      routingKey: configService.get<string>('RMQ_RECV_ROUTING_KEY'),
      queue: configService.get<string>('RMQ_RECV_QUEUE'),
      queueOptions: { durable: true },
      noAck: true,
    },
  });
  await app.startAllMicroservices();
  logger.log('RabbitMQ 마이크로서비스 연결 완료');

  app.useGlobalPipes(new ValidationPipe());

  setupSwagger(app);
  setupGlobalPrefix(app);

  // 클래스 기반 DTO 변환 + 유효성 검사를 위해 추가
  logger.log('글로벌 파이프, 인터셉터, 필터 설정 중...');
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true, // ✅ class-transformer의 @Expose, @Transform 등을 활성화
      // whitelist: true, // ✅ DTO에 정의되지 않은 속성 제거
      // forbidNonWhitelisted: true, // ✅ 정의되지 않은 속성 있으면 에러 발생
    }),
  );
  app.useGlobalInterceptors(new ResponseInterceptor());
  app.useGlobalFilters(new HttpExceptionFilter());

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  logger.log(`서버가 포트 ${port}에서 시작되었습니다`);
}
bootstrap();
