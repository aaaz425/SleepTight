import { Injectable, HttpStatus, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { firstValueFrom } from 'rxjs';
import { AxiosError } from 'axios';
import { Repository } from 'typeorm';

import { User } from 'src/users/entities/user.entity';
import { UserService } from 'src/users/user.service';
import { kakaoUser } from './interfaces/kakao.user.interface';
import { ResponseOauthLoginDto } from './dto/response-oauth-login.dto';

import { ConfigService } from '@nestjs/config';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';
import {
  throwBadRequest,
  throwNotFoundException,
  throwUnauthorizedException,
} from 'src/common/exceptions/exception.helper';
import { UserStatus } from 'src/users/user-status.enum';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly accessTokenExpiresIn: string;
  private readonly refreshTokenExpiresIn: string;
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private userService: UserService,
    private readonly configService: ConfigService,
    private httpService: HttpService,
    private jwtService: JwtService,
  ) {
    this.accessTokenExpiresIn =
      this.configService.get<string>('ACCESS_TOKEN_EXPIRES_IN') || '1d';
    this.refreshTokenExpiresIn =
      this.configService.get<string>('REFRESH_TOKEN_EXPIRES_IN') || '7d';
  }

  /** 카카오 로그인 */
  async kakaoLogin(kakaoAccessToken: string): Promise<ResponseOauthLoginDto> {
    this.logger.log('카카오 로그인 처리 시작');

    // 1) 토큰 파라미터 유효성 검사
    if (!kakaoAccessToken) {
      this.logger.warn('카카오 액세스 토큰 누락');
      throwUnauthorizedException(ExceptionCode.TOKEN_REQUIRED);
    }

    let kakaoResponse;
    try {
      // 2) 카카오 API 호출
      this.logger.debug('카카오 API 사용자 정보 요청');
      kakaoResponse = await firstValueFrom(
        this.httpService.get('https://kapi.kakao.com/v2/user/me', {
          headers: {
            Authorization: `Bearer ${kakaoAccessToken}`,
          },
        }),
      );
    } catch (error: any) {
      // AxiosError로부터 HTTP 상태 코드 확인
      if ((error as AxiosError).response?.status === HttpStatus.UNAUTHORIZED) {
        this.logger.error(
          '카카오 API 인증 실패: 유효하지 않은 토큰',
          error.stack,
        );
        throwUnauthorizedException(ExceptionCode.INVALID_TOKEN);
      }
      // 기타 요청 실패
      this.logger.error('카카오 API 요청 실패', error.stack);
      throwBadRequest(ExceptionCode.INVALID_TOKEN);
    }

    // 3) 사용자 정보 파싱
    const data = kakaoResponse.data;
    const kakaoUser: kakaoUser = {
      id: data.id.toString(),
      provider: 'kakao',
      email: data.kakao_account.email,
      name: data.kakao_account.name,
    };
    this.logger.debug(`카카오 사용자 정보 획득 - email: ${kakaoUser.email}`);

    // 4) 이메일 필수 제공 검사
    if (!kakaoUser.email) {
      this.logger.warn('카카오 API로부터 이메일 정보 누락');
      throwBadRequest(ExceptionCode.INCOMPLETE_REGISTRATION);
    }

    // 5) 사용자 조회 또는 생성
    const existingUser = await this.userRepository.findOneBy({
      email: kakaoUser.email,
    });

    if (!existingUser) {
      this.logger.log(`신규 사용자 생성 필요 - email: ${kakaoUser.email}`);
      return this.userService.createUserTemporary(kakaoUser);
    }

    this.logger.log(
      `기존 사용자 발견 - userId: ${existingUser.id}, email: ${existingUser.email}, status: ${existingUser.status}`,
    );

    // 6) 기존 사용자 로그인 처리
    const payload = {
      sub: existingUser.id,
      email: existingUser.email,
      status: existingUser.status,
    };
    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.accessTokenExpiresIn,
    });
    const refreshToken = this.jwtService.sign(payload, {
      expiresIn: this.refreshTokenExpiresIn,
    });

    existingUser.refresh_token = refreshToken;

    //휴면유저가 로그인한 경우 active로 전환
    if (existingUser.status === 'dormant') {
      this.logger.log(`휴면 사용자 활성화 - userId: ${existingUser.id}`);
      await this.userRepository.update(existingUser.id, {
        refresh_token: refreshToken,
        visited_at: new Date(),
        status: UserStatus.ACTIVE,
      });
    } else {
      this.logger.debug(
        `사용자 방문 시간 및 토큰 업데이트 - userId: ${existingUser.id}`,
      );
      await this.userRepository.update(existingUser.id, {
        refresh_token: refreshToken,
        visited_at: new Date(),
      });
    }

    this.logger.log(`카카오 로그인 성공 - userId: ${existingUser.id}`);
    return ResponseOauthLoginDto.fromEntity(
      existingUser,
      accessToken,
      refreshToken,
    );
  }

  async renewAccessToken(refreshToken: string) {
    this.logger.log('액세스 토큰 갱신 요청');

    if (!refreshToken) {
      this.logger.warn('리프레시 토큰 누락');
      throwUnauthorizedException(ExceptionCode.REFRESH_TOKEN_INVALID);
    }

    let refreshTokenPayload: any;
    //토큰이 만료되었는지 검증합니다.
    try {
      this.logger.debug('리프레시 토큰 검증');
      refreshTokenPayload = this.jwtService.verify(refreshToken);
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        this.logger.warn('리프레시 토큰 만료', error.stack);
        throwUnauthorizedException(ExceptionCode.REFRESH_TOKEN_EXPIRED);
      } else if (error.name === 'JsonWebTokenError') {
        this.logger.warn('유효하지 않은 리프레시 토큰', error.stack);
        throwUnauthorizedException(ExceptionCode.REFRESH_TOKEN_INVALID);
      }
      // 그 외 예상치 못한 검증 오류
      this.logger.error('리프레시 토큰 검증 실패', error.stack);
      throwUnauthorizedException(ExceptionCode.REFRESH_TOKEN_VERIFY_FAILED);
    }

    const userId = refreshTokenPayload.sub;
    this.logger.debug(`토큰에서 추출한 userId: ${userId}`);

    const user = await this.userRepository.findOneBy({
      id: userId,
    });

    if (!user) {
      this.logger.warn(`사용자 없음 - userId: ${userId}`);
      throwNotFoundException(ExceptionCode.USER_NOT_FOUND);
      return;
    }

    if (user.refresh_token !== refreshToken) {
      this.logger.warn(`저장된 리프레시 토큰과 불일치 - userId: ${userId}`);
      throwUnauthorizedException(ExceptionCode.REFRESH_TOKEN_INVALID);
      return;
    }

    const newPayload = {
      sub: user.id,
      email: user.email,
      status: user.status,
    };
    const newAccessToken = this.jwtService.sign(newPayload, {
      expiresIn: this.accessTokenExpiresIn,
    });

    this.logger.log(`액세스 토큰 갱신 성공 - userId: ${userId}`);
    return { accessToken: newAccessToken };
  }
}
