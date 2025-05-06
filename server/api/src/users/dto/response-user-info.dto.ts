import { User } from "src/users/entities/user.entity";

export class ResponseUserInfoDto {
    //유저 정보
    id: number;
    provider: string;
    lastName: string;
    firstName: string;
    email: string;
    wakeTime: string;
    sleepTime: string;
    minSleepDuration: string;
    weight: number
    height: number
    gender: string
    birthDate: Date
    country: string
    lengthUnit: string
    weightUnit: string
    status: string


    static fromEntity(user: User): ResponseUserInfoDto {
        const dto: ResponseUserInfoDto = new ResponseUserInfoDto();
        dto.id = user.id;
        dto.provider = user.provider??'';
        dto.lastName = user.last_name??'';
        dto.firstName = user.first_name??'';
        dto.email = user.email;
        dto.wakeTime = user.wake_time;
        dto.sleepTime = user.sleep_time;
        dto.minSleepDuration = user.min_sleep_duration;
        dto.weight = user.weight??0;
        dto.height = user.height??0;
        dto.gender = user.gender??'';
        dto.birthDate = user.birth_date??new Date();
        dto.country = user.nationality??'';
        dto.lengthUnit = user.length_unit??'' 
        dto.weightUnit = user.weight_unit??''
        dto.status = user.status??'';
        return dto; 
    }
}
