// common/filters/http-exception.filter.ts
import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpExceptionFilter.name);

  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();
    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();

    const error =
      typeof exceptionResponse === 'string'
        ? { message: exceptionResponse }
        : (exceptionResponse as any);

    this.logger.error(
      `[${request.method}] ${request.url} - ${status} | ${error.message || '에러가 발생했습니다.'} | ${error.code || 'UNKNOWN_ERROR'}`,
      exception.stack,
    );

    response.status(status).json({
      success: false,
      data: {
        status: error.status,
        message: error.message || '에러가 발생했습니다.',
        code: error.code || 'UNKNOWN_ERROR',
      },
    });
  }
}
