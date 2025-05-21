// src/auth/jwt-auth.guard.ts
import { Injectable, UnauthorizedException, Logger } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';
import {
  throwBadRequest,
  throwUnauthorizedException,
} from 'src/common/exceptions/exception.helper';
import { UserStatus } from 'src/users/user-status.enum';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  private readonly logger = new Logger(JwtAuthGuard.name);

  handleRequest(err, user, info, context) {
    const request = context.switchToHttp().getRequest();
    const path = request.path;

    this.logger.debug(`JWT 인증 검증 - path: ${path}`);

    if (err || !user) {
      const reason = info?.name;
      if (reason === 'TokenExpiredError') {
        this.logger.warn(`토큰 만료 - path: ${path}`);
        throwUnauthorizedException(ExceptionCode.TOKEN_EXPIRED);
      } else if (reason === 'JsonWebTokenError') {
        this.logger.warn(`유효하지 않은 토큰 - path: ${path}`);
        throwUnauthorizedException(ExceptionCode.INVALID_TOKEN);
      } else {
        this.logger.warn(`토큰 누락 - path: ${path}`);
        throwUnauthorizedException(ExceptionCode.TOKEN_REQUIRED);
      }
    }

    // 사용자 Status 체크
    //TODO: 탈퇴회원, 휴면회원 관리

    // 특정 경로는 상태 체크 예외 적용 안함
    const skipStatusCheckPaths = ['/api/user/register'];

    this.logger.debug(
      `사용자 상태 체크 - userId: ${user.userId}, status: ${user.status}, path: ${path}`,
    );

    if (
      user.status === UserStatus.INCOMPLETE_REGISTRATION &&
      !skipStatusCheckPaths.includes(path)
    ) {
      this.logger.warn(
        `미완료 회원가입 사용자 접근 제한 - userId: ${user.userId}, path: ${path}`,
      );
      throwBadRequest(ExceptionCode.INCOMPLETE_REGISTRATION);
    }

    this.logger.debug(`JWT 인증 성공 - userId: ${user.userId}, path: ${path}`);
    return user;
  }
}
