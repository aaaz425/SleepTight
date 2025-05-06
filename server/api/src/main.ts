import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { setupSwagger } from './common/config/swagger';
import { setupGlobalPrefix } from './common/config/prefix';

import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';
import { ValidationPipe } from '@nestjs/common';
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

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
