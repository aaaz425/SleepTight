// src/auth/jwt.strategy.ts
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  private readonly logger = new Logger(JwtStrategy.name);

  constructor(private readonly configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      secretOrKey: configService.get<string>('JWT_SECRET'),
      ignoreExpiration: false,
    });
  }

  async validate(payload: any) {
    this.logger.debug(
      `JWT 페이로드 검증 - userId: ${payload.sub}, email: ${payload.email}, status: ${payload.status}`,
    );
    return {
      userId: payload.sub,
      email: payload.email,
      status: payload.status,
    };
  }
}
