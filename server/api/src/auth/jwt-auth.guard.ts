// src/auth/jwt-auth.guard.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { throwUnauthorizedException } from 'src/common/exceptions/error.helper';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
    handleRequest(err, user, info, context) {
        if (err || !user) {
            const reason = info?.name;
            if(reason === 'TokenExpiredError') {
                throwUnauthorizedException('엑세스 토큰이 만료되었습니다', "TOKEN_EXPIRED");
            } else if(reason === 'JsonWebTokenError') {
                throwUnauthorizedException('유효하지 않은 토큰입니다.','INVALID_TOKEN');
            } else {
                throwUnauthorizedException('인증 토큰이 없습니다.','Authentication required.');
            }
        }
        return user;
    }
}