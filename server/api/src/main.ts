import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { setupSwagger } from './common/config/swagger';
import { setupGlobalPrefix } from './common/config/prefix';
import { ValidationPipe } from '@nestjs/common';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { ConfigService } from '@nestjs/config';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';
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
  //     queue: 'sleep.analysis.queue',
  //     queueOptions: { durable: false },
  //   },
  // });

  // await app.startAllMicroservices();

  app.useGlobalPipes(new ValidationPipe());

  setupSwagger(app);
  setupGlobalPrefix(app);

  // 클래스 기반 DTO 변환 + 유효성 검사를 위해 추가
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true, // ✅ class-transformer의 @Expose, @Transform 등을 활성화
      // whitelist: true, // ✅ DTO에 정의되지 않은 속성 제거
      // forbidNonWhitelisted: true, // ✅ 정의되지 않은 속성 있으면 에러 발생
    }),
  );
  app.useGlobalInterceptors(new ResponseInterceptor());
  app.useGlobalFilters(new HttpExceptionFilter());

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
