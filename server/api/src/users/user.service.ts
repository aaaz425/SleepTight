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

    async create(user: User): Promise<User> {
        const newUser = this.userRepository.create(user);
        return this.userRepository.save(newUser);
    }
    
    async getUserInfo(id: number): Promise<ResponseUserInfoDto> {
        const user = await this.findById(id);
        const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
        return responseUserInfoDto;
    }

    async findByEmail(email: string): Promise<User | null> {
        const user = await this.userRepository.findOneBy({ email });
        return user;
    }

    async updateName(id: number, name: string): Promise<User> {
        const user = await this.findById(id);
        user.first_name= name;
        return this.userRepository.save(user);
    }

    private async findById(id: number): Promise<User> {
        const user = await this.userRepository.findOneBy({ id });
        if (!user) {
            throwNotFoundException("유저를 찾을 수 없습니다.", "USER_NOT_FOUND");
        }
        return user;
    }
}