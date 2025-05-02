import { User } from "src/users/entities/user.entity"

export class ResponseJoinDto {

    accessToken :string
    id: number
    status :string
    
    static fromEntity(user: User, accessToken :string) :ResponseJoinDto {
        const dto :ResponseJoinDto = new ResponseJoinDto();
        dto.accessToken = accessToken;
        dto.id = user.id;
        dto.status = user.status??"";
        return dto;
    }
}