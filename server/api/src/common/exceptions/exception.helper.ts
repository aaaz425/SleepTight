import { HttpException, HttpStatus, Logger } from '@nestjs/common';

const logger = new Logger('ExceptionHelper');

export function throwBadRequest(ExceptionCodeKey): never {
  logger.warn(
    `BadRequest 예외 발생: [${ExceptionCodeKey.code}] ${ExceptionCodeKey.message}`,
  );
  throw new HttpException(
    {
      status: ExceptionCodeKey.status,
      message: ExceptionCodeKey.message,
      code: ExceptionCodeKey.code,
    },
    HttpStatus.BAD_REQUEST,
  );
}

export function throwUnauthorizedException(ExceptionCodeKey): never {
  logger.warn(
    `Unauthorized 예외 발생: [${ExceptionCodeKey.code}] ${ExceptionCodeKey.message}`,
  );
  throw new HttpException(
    {
      status: ExceptionCodeKey.status,
      message: ExceptionCodeKey.message,
      code: ExceptionCodeKey.code,
    },
    HttpStatus.UNAUTHORIZED,
  );
}

export function throwNotFoundException(ExceptionCodeKey): never {
  logger.warn(
    `NotFound 예외 발생: [${ExceptionCodeKey.code}] ${ExceptionCodeKey.message}`,
  );
  throw new HttpException(
    {
      status: ExceptionCodeKey.status,
      message: ExceptionCodeKey.message,
      code: ExceptionCodeKey.code,
    },
    HttpStatus.NOT_FOUND,
  );
}

export function throwInternalServerError(ExceptionCodeKey): never {
  logger.error(
    `서버 내부 오류 발생: [${ExceptionCodeKey.code ?? 'INTERNAL_SERVER_ERROR'}] ${ExceptionCodeKey.message ?? '내부 서버 오류'}`,
  );
  throw new HttpException(
    {
      status: ExceptionCodeKey.status ?? 500,
      message: ExceptionCodeKey.message ?? '내부 서버 오류',
      code: ExceptionCodeKey.code ?? 'INTERNAL_SERVER_ERROR',
    },
    HttpStatus.INTERNAL_SERVER_ERROR,
  );
}
