import { Expose } from "class-transformer";
import { User } from "../entities/user.entity";
import { UserStatus } from "../user-status.enum";
import { ApiProperty } from "@nestjs/swagger";

export class RequestRegisterUserInfoDto {
    //유저 정보
    @ApiProperty()
    @Expose({ name: 'first_name' })
    firstName :string;

    @ApiProperty()
    @Expose({ name: 'last_name' })
    lastName :string;
    
    @ApiProperty()
    gender :string
    
    @ApiProperty()
    @Expose({ name: 'birth_date' })
    birthDate :Date

    @ApiProperty()
    country :string

    @ApiProperty()
    weight: number

    @ApiProperty()
    height: number

    @ApiProperty()
    @Expose({ name: 'length_unit' })
    lengthUnit: string

    @ApiProperty()
    @Expose({ name: 'weight_unit' })
    weightUnit: string

    @ApiProperty()
    @Expose({name:"fcm_token"})
    fcmToken: string

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
        user.status = UserStatus.ACTIVE;
        user.fcm_token = userInfo.fcmToken;
        return user;
    }
}