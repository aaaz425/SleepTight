import { HttpService } from "@nestjs/axios";
import { Injectable } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { firstValueFrom } from "rxjs";
import { User } from "src/users/entities/user.entity";
import { UserService } from "src/users/user.service";

@Injectable()
export class AuthService {
    constructor(
        private userService: UserService,
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
        const kakaoUser = kakaoResponse.data;
        const kakaoId = kakaoUser.id; //이메일로만 인증하면 필요없음
        //HACK: 이메일 제공 동의를 안하면 이메일이 안넘어 옴.
        //일단 배제하고 구현했습니다.
        const email = kakaoUser.kakao_account?.email;
        
        const user = await this.findOrCreateUser(email);
    }
    
    private async findOrCreateUser(email: string): Promise<User | null> {
        const user = await this.userService.findByEmail(email);
        if(user) {
            return user;    
        }
        console.log('새로운 유저입니다. 로직을 추가하세요');
        return user;
    }
}