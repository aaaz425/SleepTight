import { User } from 'src/users/entities/user.entity';

export class ResponseOauthLoginDto {
  id: number;
  email: string;
  status: string | null;
  accessToken: string;
  refreshToken: string;

  static fromEntity(
    user: User,
    accessToken: string,
    refreshToken: string,
  ): ResponseOauthLoginDto {
    const dto = new ResponseOauthLoginDto();
    dto.id = user.id;
    dto.email = user.email;
    dto.status = user.status;
    dto.accessToken = accessToken;
    dto.refreshToken = refreshToken;
    return dto;
  }
}
