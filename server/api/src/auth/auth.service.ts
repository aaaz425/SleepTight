import { Injectable, HttpStatus } from '@nestjs/common';
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

@Injectable()
export class AuthService {
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
    // 1) 토큰 파라미터 유효성 검사
    if (!kakaoAccessToken) {
      throwUnauthorizedException(ExceptionCode.TOKEN_REQUIRED);
    }

    let kakaoResponse;
    try {
      // 2) 카카오 API 호출
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
        throwUnauthorizedException(ExceptionCode.INVALID_TOKEN);
      }
      // 기타 요청 실패
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

    // 4) 이메일 필수 제공 검사
    if (!kakaoUser.email) {
      throwBadRequest(ExceptionCode.INCOMPLETE_REGISTRATION);
    }

    // 5) 사용자 조회 또는 생성
    const existingUser = await this.userRepository.findOneBy({
      email: kakaoUser.email,
    });
    if (!existingUser) {
      return this.userService.createUserTemporary(kakaoUser);
    }

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
    await this.userRepository.update(existingUser.id, 
      {
        refresh_token: refreshToken,
        visited_at : new Date()
      });

    return ResponseOauthLoginDto.fromEntity(
      existingUser,
      accessToken,
      refreshToken,
    );
  }

  async renewAccessToken(refreshToken: string) {
    let refreshTokenPayload: any;
    //토큰이 만료되었는지 검증합니다.
    try {
      refreshTokenPayload = this.jwtService.verify(refreshToken);
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throwUnauthorizedException(ExceptionCode.REFRESH_TOKEN_EXPIRED);
      } else if (error.name === 'JsonWebTokenError') {
        throwUnauthorizedException(ExceptionCode.REFRESH_TOKEN_INVALID);
      }
      // 그 외 예상치 못한 검증 오류
      throwUnauthorizedException(ExceptionCode.REFRESH_TOKEN_VERIFY_FAILED);
    }

    const user = await this.userRepository.findOneBy({
      id: refreshTokenPayload.sub,
    });
    if (!user) {
      throwNotFoundException(ExceptionCode.USER_NOT_FOUND);
      return;
    }
    if (user.refresh_token !== refreshToken) {
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
    return { accessToken: newAccessToken };
  }
}
