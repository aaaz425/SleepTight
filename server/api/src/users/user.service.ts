import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { User } from "./entities/user.entity";
import { Repository } from "typeorm";
import { ResponseUserInfoDto } from "./dto/response-userInfo.dto";
import { throwNotFoundException } from "src/common/exceptions/error.helper";
import { count } from "console";


@Injectable()
export class UserService {
    constructor(
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
    ) { }

    // 사용자 정보 조회
    async getUserInfo(id: number): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
        return responseUserInfoDto;
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
    // userId로 사용자 조회
    private async findById(id: number): Promise<User> {
        const user = await this.userRepository.findOneBy({ id });
        if (!user) {
            throwNotFoundException("유저를 찾을 수 없습니다.", "USER_NOT_FOUND");
        }
        return user;
    }
}