import { HttpException, HttpStatus } from '@nestjs/common';

export function throwBadRequest(ExceptionCodeKey) {
  throw new HttpException(
    {
      status: ExceptionCodeKey.status,
      message: ExceptionCodeKey.message,
      code: ExceptionCodeKey.code,
    },
    HttpStatus.BAD_REQUEST,
  );
}

export function throwUnauthorizedException(ExceptionCodeKey) {
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
  throw new HttpException(
    {
      status: ExceptionCodeKey.status ?? 500,
      message: ExceptionCodeKey.message ?? '내부 서버 오류',
      code: ExceptionCodeKey.code ?? 'INTERNAL_SERVER_ERROR',
    },
    HttpStatus.INTERNAL_SERVER_ERROR,
  );
}
