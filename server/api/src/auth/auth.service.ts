import { HttpService } from "@nestjs/axios";
import { HttpException, HttpStatus, Injectable } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { InjectRepository } from "@nestjs/typeorm";
import { firstValueFrom } from "rxjs";
import { User } from "src/users/entities/user.entity";
import { Repository } from "typeorm";
import { kakaoUser } from "./interfaces/kakao.user.interface";
import { throwBadRequest } from "src/common/exceptions/error.helper";
import { ResponseLoginDto } from "./dto/response-login.dto";
import { ResponseJoinDto } from "./dto/response-join.dto";
import { ResponseOauthLoginDto } from "./dto/response-oauth-login.dto";

@Injectable()
export class AuthService {
    constructor(
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
        private httpService: HttpService,
        private jwtService: JwtService
    ) {}

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
        if(!email) {
            throw new Error('이메일이 제공되지 않았습니다. 카카오 계정에서 이메일 제공을 허용해주세요.');
        }

        //제공받은 이메일로 유저를 찾거나 생성합니다.
        const user = await this.userRepository.findOneBy(
            { email: email }
        );
        if(!user) {
            //유저가 없으면 생성합니다.
            const kakaoId: string = kakaoUser.id.toString();
            const dto :Promise<ResponseOauthLoginDto> = this.createUserTemporary(kakaoUser);
            return dto;
        } else {
            //유저가 있으면 리턴
            const payload = {
                sub: user.id,
                email: user.email,
                status: user.status
            };
            const accessToken = this.jwtService.sign(payload, { expiresIn: '1h' });
            const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });
            user.refresh_token = refreshToken;
            await this.userRepository.save(user);
            const dto :ResponseOauthLoginDto = ResponseOauthLoginDto.fromEntity(user, accessToken, refreshToken)
            return dto;
        }
    }

    private async createUserTemporary(kakaoUser: kakaoUser): Promise<ResponseOauthLoginDto>  {
        const tempUser = new User();
        tempUser.serial_number = kakaoUser.id;
        tempUser.provider = kakaoUser.provider;
        tempUser.email = kakaoUser.email;
        tempUser.status = 'Incomplete Registration';
        const newUser :User = await this.userRepository.save(tempUser);
        //JWT 토큰 발급
        const payload = { 
            sub: newUser.id,
            email: newUser.email,
            status: newUser.status
        };
        const accessToken = this.jwtService.sign(payload, { expiresIn: '1h' });
        const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });
        
        newUser.refresh_token = refreshToken;
        await this.userRepository.save(newUser);
        const dto :ResponseOauthLoginDto = ResponseOauthLoginDto.fromEntity(newUser, accessToken, refreshToken)
        return dto;
    }
}