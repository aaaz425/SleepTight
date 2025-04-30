import { Body, Controller, Post } from "@nestjs/common";
import { AuthService } from "./auth.service";

@Controller('api/auth')
export class AuthController {
    constructor(
        private readonly authService: AuthService
    ){}

    @Post('kakao')
    async kakaoLogin(@Body('access_token') accessToken: string) {
        return this.authService.kakaoLogin(accessToken);
    }
} 