import { HttpService } from "@nestjs/axios";
import { HttpException, HttpStatus, Injectable } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { InjectRepository } from "@nestjs/typeorm";
import { firstValueFrom } from "rxjs";
import { User } from "src/users/entities/user.entity";
import { Repository } from "typeorm";
import { kakaoUser } from "./interfaces/kakao.user.interface";
import { throwBadRequest } from "src/common/exceptions/error.helper";

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
        console.log(kakaoResponse);
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
            this.createUser(kakaoUser);
        } else if(user.status === 'Incomplete Registration') {
            //유저가 있지만 가입이 완료되지 않았으면 에러를 던집니다.
            throwBadRequest('가입이 완료되지 않았습니다.', 'INCOMPLETE_REGISTRATION');
        } else {
            //유저가 있으면 로그인
            this.login(user)
        }
    }

    //TODO: 로그인 후 JWT 토큰을 발급하고 유저 정보를 반환합니다.
    private async login(user: User) {
        const payload = { email: user.email, sub: user.id };
        const accessToken = this.jwtService.sign(payload, {
            secret: process.env.JWT_SECRET,
            expiresIn: '1h',
        });
        return {
            access_token: accessToken,
            user: user,
        };
    }
    private async createUser(kakaoUser: kakaoUser): Promise<User>  {
        const newUser = new User();
        newUser.serial_number = kakaoUser.id;
        newUser.provider = kakaoUser.provider;
        newUser.email = kakaoUser.email;
        newUser.status = 'Incomplete Registration';
        return await this.userRepository.save(newUser)
    }
}