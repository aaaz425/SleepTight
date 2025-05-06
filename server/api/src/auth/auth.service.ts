import { HttpService } from "@nestjs/axios";
import { HttpException, HttpStatus, Injectable } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { InjectRepository } from "@nestjs/typeorm";
import { firstValueFrom } from "rxjs";
import { User } from "src/users/entities/user.entity";
import { Repository } from "typeorm";
import { kakaoUser } from "./interfaces/kakao.user.interface";
import { throwBadRequest, throwUnauthorizedException } from "src/common/exceptions/error.helper";
import { ResponseOauthLoginDto } from "./dto/response-oauth-login.dto";
import { ConfigService } from "@nestjs/config";

@Injectable()
export class AuthService {
    private readonly accessTokenExpiresIn: string;
    private readonly refreshTokenExpiresIn: string;
    constructor(
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
        private readonly configService: ConfigService,
        private httpService: HttpService,
        private jwtService: JwtService
    ) {
        this.accessTokenExpiresIn = this.configService.get<string>('ACCESS_TOKEN_EXPIRES_IN') || '1d';
        this.refreshTokenExpiresIn = this.configService.get<string>('REFRESH_TOKEN_EXPIRES_IN') || '7d';
    }

    async kakaoLogin(kakaoAccessToken: string) {
        const kakaoResponse = await firstValueFrom(
            this.httpService.get('https://kapi.kakao.com/v2/user/me', {
                headers: {
                    Authorization: `Bearer ${kakaoAccessToken}`,
                }
            })
        )
        //카카오로 부터 받는 정보는 최소한(id, email, name)으로 생각하고 구현했습니다.
        const data = kakaoResponse.data;
        const kakaoUser: kakaoUser = {
            id: data.id.toString(),
            provider: 'kakao',
            email: data.kakao_account.email,
            name: data.kakao_account.name
        }

        //HACK: 이메일 제공 동의를 안하면 이메일이 안넘어 옴.
        //일단 배제하고 구현.
        const email: string = kakaoUser.email;
        if (!email) {
            throw new Error('이메일이 제공되지 않았습니다. 카카오 계정에서 이메일 제공을 허용해주세요.');
        }

        //제공받은 이메일로 유저를 찾거나 생성합니다.
        const user = await this.userRepository.findOneBy(
            { email: email }
        );
        if (!user) {
            //유저가 없으면 생성합니다.
            const kakaoId: string = kakaoUser.id.toString();
            const dto: Promise<ResponseOauthLoginDto> = this.createUserTemporary(kakaoUser);
            return dto;
        } else {
            //유저가 있으면 리턴
            const payload = {
                sub: user.id,
                email: user.email,
                status: user.status
            };
            const accessToken = this.jwtService.sign(payload, {expiresIn: this.accessTokenExpiresIn});
            const refreshToken = this.jwtService.sign(payload, {expiresIn: this.refreshTokenExpiresIn});
            user.refresh_token = refreshToken;
            await this.userRepository.update(user.id, { refresh_token: refreshToken });
            const dto: ResponseOauthLoginDto = ResponseOauthLoginDto.fromEntity(user, accessToken, refreshToken)
            return dto;
        }
    }

    private async createUserTemporary(kakaoUser: kakaoUser): Promise<ResponseOauthLoginDto> {
        const tempUser = new User();
        tempUser.serial_number = kakaoUser.id;
        tempUser.provider = kakaoUser.provider;
        tempUser.email = kakaoUser.email;
        tempUser.status = 'Incomplete Registration';
        const newUser: User = await this.userRepository.save(tempUser);
        //JWT 토큰 발급
        const payload = {
            sub: newUser.id,
            email: newUser.email,
            status: newUser.status
        };
        const accessToken = this.jwtService.sign(payload, {expiresIn: this.accessTokenExpiresIn});
        const refreshToken = this.jwtService.sign(payload, {expiresIn: this.refreshTokenExpiresIn});
        newUser.refresh_token = refreshToken;
        await this.userRepository.update(newUser.id, { refresh_token: refreshToken });
        const dto: ResponseOauthLoginDto = ResponseOauthLoginDto.fromEntity(newUser, accessToken, refreshToken)
        return dto;
    }

    async refreshToken(refreshToken: string) {
        let refreshTokenPayload: any;
        //토큰이 만료되었는지 검증합니다.
        try {
            refreshTokenPayload = this.jwtService.verify(refreshToken);
        } catch (error) {
            if (error.name === 'TokenExpiredError') {
                throwUnauthorizedException('Refresh Token이 만료되었습니다.', 'REFRESH_TOKEN_EXPIRED');
            } else if (error.name === 'JsonWebTokenError') {
                throwUnauthorizedException('Refresh Token이 위조되었거나 잘못되었습니다.', 'REFRESH_TOKEN_INVALID');
            }
            // 그 외 예상치 못한 검증 오류
            throwUnauthorizedException('Refresh Token 검증에 실패했습니다.', 'REFRESH_TOKEN_VERIFY_FAILED');
        }

        const user = await this.userRepository.findOneBy({ id: refreshTokenPayload.sub });
        if (!user) {
            throwUnauthorizedException('유저를 찾을 수 없습니다.', 'USER_NOT_FOUND');
            return;
        }
        if (user.refresh_token !== refreshToken) {
            throwUnauthorizedException('Refresh Token이 위조되었거나 잘못되었습니다.', 'REFRESH_TOKEN_INVALID');
            return;
        }
        const newPayload = {
            sub: user.id,
            email: user.email,
            status: user.status
        };
        const newAccessToken = this.jwtService.sign(newPayload, { expiresIn: this.accessTokenExpiresIn });
        return { accessToken: newAccessToken };
    }
}