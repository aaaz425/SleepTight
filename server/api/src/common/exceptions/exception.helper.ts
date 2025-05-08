import { HttpException, HttpStatus } from "@nestjs/common";

export function throwBadRequest(ExceptionCodeKey) {
    throw new HttpException(
        {
            status: ExceptionCodeKey.status,
            message: ExceptionCodeKey.message,
            code: ExceptionCodeKey.code
        },
        HttpStatus.BAD_REQUEST,
    );
}


export function throwUnauthorizedException(ExceptionCodeKey) {
    throw new HttpException(
        {
            status: ExceptionCodeKey.status,
            message: ExceptionCodeKey.message,
            code: ExceptionCodeKey.code
        },
        HttpStatus.UNAUTHORIZED
    );
}

export function throwNotFoundException(ExceptionCodeKey) :never{
    throw new HttpException(
        {
            status: ExceptionCodeKey.status,
            message: ExceptionCodeKey.message,
            code: ExceptionCodeKey.code
        },
        HttpStatus.NOT_FOUND
    );
}