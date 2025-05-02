import { INestApplication, RequestMethod } from '@nestjs/common';

/**
 * 글로벌 API Prefix 설정
 *
 * @param {INestApplication} app
 */
export function setupGlobalPrefix(app: INestApplication): void {
  app.setGlobalPrefix('api', {
    exclude: [
      { path: 'api-docs', method: RequestMethod.GET },
      { path: 'api-docs-json', method: RequestMethod.GET },
    ],
  });
}
