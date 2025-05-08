// src/auth/jwt-auth.guard.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';
import { throwBadRequest, throwUnauthorizedException } from 'src/common/exceptions/exception.helper';
import { UserStatus } from 'src/users/user-status.enum';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
    handleRequest(err, user, info, context) {
        if (err || !user) {
            const reason = info?.name;
            if (reason === 'TokenExpiredError') {
                throwUnauthorizedException(ExceptionCode.TOKEN_EXPIRED);
            } else if (reason === 'JsonWebTokenError') {
                throwUnauthorizedException(ExceptionCode.INVALID_TOKEN);
            } else {
                throwUnauthorizedException(ExceptionCode.TOKEN_REQUIRED);
            }
        }

        // 사용자 Status 체크
        //TODO: 탈퇴회원, 휴면회원 관리

        const request = context.switchToHttp().getRequest();
        const path = request.path;
        // 특정 경로는 상태 체크 예외 적용 안함
        const skipStatusCheckPaths = ['/api/user/register'];
        if (user.status === UserStatus.INCOMPLETE_REGISTRATION && !skipStatusCheckPaths.includes(path)) {
            throwBadRequest(ExceptionCode.INCOMPLETE_REGISTRATION);
        }
        return user;
    }
}