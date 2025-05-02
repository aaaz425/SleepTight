import { Body, Controller, HttpCode, Post } from "@nestjs/common";
import { AuthService } from "./auth.service";

@Controller('api/auth')
export class AuthController {
    constructor(
        private readonly authService: AuthService
    ){}

    @HttpCode(200)
    @Post('kakao')
    async kakaoLogin(@Body('AuthroziationCode') accessToken: string) {
        return this.authService.kakaoLogin(accessToken);
    }
} 