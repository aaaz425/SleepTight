import { Body, Controller, HttpCode, Post } from "@nestjs/common";
import { AuthService } from "./auth.service";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("AUTH")
@Controller('auth')
export class AuthController {
    constructor(
        private readonly authService: AuthService
    ){}

    @ApiOperation({ summary: '카카오 로그인' })
    @HttpCode(200)
    @Post('kakao')
    async kakaoLogin(@Body('AuthroziationCode') accessToken: string) {
        return this.authService.kakaoLogin(accessToken);
    }

    @ApiOperation({ summary: '엑세스 토큰 리프레시' })
    @HttpCode(200)
    @Post('refresh')
    async refreshToken(@Body('refreshToken') refreshToken: string) {
        return this.authService.renewAccessToken(refreshToken);
    }
} 