import { Body, Controller, HttpCode, Post, Logger } from '@nestjs/common';
import { AuthService } from './auth.service';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

@ApiTags('AUTH')
@Controller('auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name);

  constructor(private readonly authService: AuthService) {}

  @ApiOperation({ summary: '카카오 로그인' })
  @HttpCode(200)
  @Post('kakao')
  async kakaoLogin(@Body('AuthorizationCode') accessToken: string) {
    this.logger.log('카카오 로그인 요청');
    try {
      const result = await this.authService.kakaoLogin(accessToken);
      this.logger.log('카카오 로그인 성공');
      return result;
    } catch (error) {
      this.logger.error('카카오 로그인 실패', error.stack);
      throw error;
    }
  }

  @ApiOperation({ summary: '엑세스 토큰 리프레시' })
  @HttpCode(200)
  @Post('refresh')
  async refreshToken(@Body('refreshToken') refreshToken: string) {
    this.logger.log('토큰 갱신 요청');
    try {
      const result = await this.authService.renewAccessToken(refreshToken);
      this.logger.log('토큰 갱신 성공');
      return result;
    } catch (error) {
      this.logger.error('토큰 갱신 실패', error.stack);
      throw error;
    }
  }
}
