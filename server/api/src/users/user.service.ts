import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { User } from "./entities/user.entity";
import { Repository } from "typeorm";
import { ResponseUserInfoDto } from "./dto/response-user-info.dto";
import { throwNotFoundException } from "src/common/exceptions/error.helper";
import { RequestRegisterUserInfoDto } from "./dto/request-register-user-info.dto";
import { ResponseUserInfoWithTokensDto } from "./dto/response-user-info-with-tokens.dto";
import { JwtService } from "@nestjs/jwt";
import { ConfigService } from "@nestjs/config";
import { UserStatus } from "./user-status.enum";
import { kakaoUser } from "src/auth/interfaces/kakao.user.interface";
import { ResponseOauthLoginDto } from "src/auth/dto/response-oauth-login.dto";


@Injectable()
export class UserService {
    private readonly accessTokenExpiresIn: string;
    private readonly refreshTokenExpiresIn: string;
    constructor(
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
        private jwtService: JwtService,
        private readonly configService: ConfigService,
    ) {
        this.accessTokenExpiresIn = this.configService.get<string>('ACCESS_TOKEN_EXPIRES_IN') || '1d';
        this.refreshTokenExpiresIn = this.configService.get<string>('REFRESH_TOKEN_EXPIRES_IN') || '7d';
    }

    // 사용자 정보 조회
    async getUserInfo(id: number): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
        return responseUserInfoDto;
    }

    //사용자 임시 회원가입(authService에서 콜함)
    async createUserTemporary(kakaoUser: kakaoUser): Promise<ResponseOauthLoginDto> {
        const tempUser = new User();
        tempUser.serial_number = kakaoUser.id;
        tempUser.provider = kakaoUser.provider;
        tempUser.email = kakaoUser.email;
        tempUser.status = UserStatus.INCOMPLETE_REGISTRATION;
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

    // 사용자 이름 변경
    async updateName(id: number, firstName: string, lastName: string): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        user.first_name = firstName;
        user.last_name = lastName;
        await this.userRepository.update(
            user.id, {
            first_name: firstName,
            last_name: lastName
        }
        );
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
        return responseUserInfoDto;
    }

    // 사용자 생년월일 변경
    async updateBirthdate(id: number, birthDate: Date): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        user.birth_date = birthDate
        await this.userRepository.update(
            user.id, {
            birth_date: birthDate
        }
        );
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
        return responseUserInfoDto;
    }

    // 사용자 성별 변경
    async updateGender(id: number, gender: string): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        user.gender = gender
        await this.userRepository.update(
            user.id, {
            gender: gender
        }
        );
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
        return responseUserInfoDto;
    }

    // 사용자 국적 변경
    async updateCountry(id: number, country: string): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        user.nationality = country
        await this.userRepository.update(
            user.id, {
            nationality: country
        }
        );
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
        return responseUserInfoDto;
    }

    // 사용자 키 변경
    async updateHeight(id: number, height: number): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        user.height = height
        await this.userRepository.update(
            user.id, {
            height: height
        }
        );
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
        return responseUserInfoDto;
    }

    // 사용자 몸무게 변경
    async updateWeight(id: number, weight: number): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        user.weight = weight
        await this.userRepository.update(
            user.id, {
            weight: weight
        }
        );
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
        return responseUserInfoDto;
    }

    // 사용자 목표 수면 시간 변경
    async updateMinSleepDuration(id: number, minSleepDuration: string): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        user.min_sleep_duration = minSleepDuration
        await this.userRepository.update(
            user.id, { min_sleep_duration : minSleepDuration }
        );
        const updatedUser = await this.findById(id);
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(updatedUser);
        return responseUserInfoDto;
    }

    // 사용자 취침 시간 변경
    async updateSleepTime(id: number, sleepTime: string): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        user.sleep_time = sleepTime
        await this.userRepository.update(
            user.id, { sleep_time : sleepTime }
        );
        const updatedUser = await this.findById(id);
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(updatedUser);
        return responseUserInfoDto;
    }
    
    // 사용자 기상 시간 변경
    async updateWakeTime(id: number, wakeTime: string): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        user.wake_time = wakeTime
        await this.userRepository.update(
            user.id, { wake_time : wakeTime }
        );
        const updatedUser = await this.findById(id);
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(updatedUser);
        return responseUserInfoDto;
    }

    // 사용자 초기 정보 등록
    async registerUserInfo(id: number, userInfo: RequestRegisterUserInfoDto): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        RequestRegisterUserInfoDto.toEntity(userInfo, user);

        //새롭게 JWT 토큰 발급
        const payload = {
            sub: user.id,
            email: user.email,
            status: user.status
        };
        const accessToken = this.jwtService.sign(payload, {expiresIn: this.accessTokenExpiresIn});
        const refreshToken = this.jwtService.sign(payload, {expiresIn: this.refreshTokenExpiresIn});
        user.refresh_token = refreshToken;
        const updatedUser = await this.userRepository.save(user);
        const responseUserInfoWithTokensDto = ResponseUserInfoWithTokensDto.fromEntity(updatedUser, accessToken, refreshToken);

        return responseUserInfoWithTokensDto;
    }


    // userId로 사용자 조회
    private async findById(id: number): Promise<User> {
        const user = await this.userRepository.findOneBy({ id });
        if (!user) {
            throwNotFoundException("유저를 찾을 수 없습니다.", "USER_NOT_FOUND");
        }
        return user;
    }

    //사용자 로그아웃
    async logout(userId :number) {
        const user = await this.findById(userId);
        //refresh_Token ''으로 수정
        this.userRepository.update(userId, {refresh_token : ''});
    }

    //사용자 탈퇴
    async withdraw(userId :number) {
        const user = await this.findById(userId);
        //refresh_Token ''으로 수정
        this.userRepository.update(userId, {
            refresh_token : '',
            status : UserStatus.PENDING_WITHDRAW,
            withdrawal_at : new Date()
        });
    }

    // 탈퇴 보류 회원 복구
    async reinstate(userId :number) {
        const user = await this.findById(userId);
        //새롭게 JWT 토큰 발급
        const payload = {
            sub: user.id,
            email: user.email,
            status: user.status
        };
        const accessToken = this.jwtService.sign(payload, {expiresIn: this.accessTokenExpiresIn});
        const refreshToken = this.jwtService.sign(payload, {expiresIn: this.refreshTokenExpiresIn});
        this.userRepository.update(userId,{
            status : UserStatus.ACTIVE,
            refresh_token : refreshToken,
            withdrawal_at : null
        });
        const responseUserInfoWithTokensDto = ResponseUserInfoWithTokensDto.fromEntity(user, accessToken, refreshToken);
        return responseUserInfoWithTokensDto;
    }
}