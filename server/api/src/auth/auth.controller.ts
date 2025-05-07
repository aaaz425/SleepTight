import { Body, Controller, HttpCode, Post } from "@nestjs/common";
import { AuthService } from "./auth.service";

@Controller('auth')
export class AuthController {
    constructor(
        private readonly authService: AuthService
    ){}

    @HttpCode(200)
    @Post('kakao')
    async kakaoLogin(@Body('AuthroziationCode') accessToken: string) {
        return this.authService.kakaoLogin(accessToken);
    }

    @HttpCode(200)
    @Post('refresh')
    async refreshToken(@Body('refreshToken') refreshToken: string) {
        return this.authService.renewAccessToken(refreshToken);
    }
} 