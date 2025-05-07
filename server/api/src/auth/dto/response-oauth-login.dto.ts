import { User } from "src/users/entities/user.entity"

export class ResponseOauthLoginDto {

    accessToken :string
    refreshToken :string
    status :string
    
    static fromEntity(user: User, accessToken :string, refreshToken :string) :ResponseOauthLoginDto {
        const dto :ResponseOauthLoginDto = new ResponseOauthLoginDto();
        dto.accessToken = accessToken;
        dto.refreshToken = refreshToken
        dto.status = user.status??"";
        return dto;
    }
}