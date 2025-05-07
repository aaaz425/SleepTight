import { Expose } from "class-transformer";
import { User } from "../entities/user.entity";

export class RequestRegisterUserInfoDto {
    //유저 정보
    @Expose({ name: 'first_name' })
    firstName :string;
    @Expose({ name: 'last_name' })
    lastName :string;
    gender :string
    @Expose({ name: 'birth_date' })
    birthDate :Date
    country :string
    weight: number
    height: number
    @Expose({ name: 'length_unit' })
    lengthUnit: string
    @Expose({ name: 'weight_unit' })
    weightUnit: string

    static toEntity(userInfo: RequestRegisterUserInfoDto, user :User): User{
        user.first_name = userInfo.firstName;
        user.last_name = userInfo.lastName;
        user.gender = userInfo.gender;
        user.birth_date = userInfo.birthDate;
        user.nationality = userInfo.country;
        user.weight = userInfo.weight;
        user.height = userInfo.height;
        user.length_unit = userInfo.lengthUnit;
        user.weight_unit = userInfo.weightUnit;
        return user;
    }
}