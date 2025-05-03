import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { User } from "./entities/user.entity";
import { Repository } from "typeorm";
import { ResponseUserInfoDto } from "./dto/response-userInfo.dto";
import { throwNotFoundException } from "src/common/exceptions/error.helper";


@Injectable()
export class UserService {
    constructor(
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
    ) {}

    // 사용자 정보 조회
    async getUserInfo(id: number): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
        return responseUserInfoDto;
    }

    // 사용자 이름 변경
    async updateName(id: number, firstName: string, lastName :string): Promise<ResponseUserInfoDto> {
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
    async updateBirthdate(id: number, birthDate :Date): Promise<ResponseUserInfoDto> {
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
    async updateGender(id: number, gender :string): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        user.gender = gender
        await this.userRepository.update(
            user.id, {
                gender : gender 
            }
        );
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
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