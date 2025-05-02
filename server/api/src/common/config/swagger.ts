import { INestApplication } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

/**
 * Swagger 세팅
 *
 * @param {INestApplication} app
 */
export function setupSwagger(app: INestApplication): void {
  const options = new DocumentBuilder()
    .setTitle('Sleep Tight API Docs')
    .setDescription('Sleep Tight API description')
    .setVersion('1.0.0')
    // .addBearerAuth({
    //   type: 'http',
    //   scheme: 'bearer',
    //   bearerFormat: 'JWT',
    //   name: 'Authorization',
    //   in: 'header',
    // }) // ✅ JWT 인증 사용 시 주석 해제 (Controller에 @ApiBearerAuth() 추가해 사용)
    .addServer('/api')
    .build();

  const document = SwaggerModule.createDocument(app, options);
  SwaggerModule.setup('api-docs', app, document);
}
