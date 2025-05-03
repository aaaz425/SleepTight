import { HttpException, HttpStatus } from "@nestjs/common";

export function throwBadRequest(message: string, code: string) {
    throw new HttpException(
        {
            status: HttpStatus.BAD_REQUEST,
            error: message,
            code: code, // 에러코드 숫자코드로 할지? 문자코드로 할지?
        },
        HttpStatus.BAD_REQUEST,
    );
}

export function throwUnauthorizedException(message: string, code: string) {
    throw new HttpException(
        {
            status: HttpStatus.UNAUTHORIZED,
            error: message,
            code: code
        },
        HttpStatus.UNAUTHORIZED
    );
}