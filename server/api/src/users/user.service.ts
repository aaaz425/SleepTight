import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { Repository } from 'typeorm';
import { ResponseUserInfoDto } from './dto/response-user-info.dto';
import { throwNotFoundException } from 'src/common/exceptions/exception.helper';
import { RequestRegisterUserInfoDto } from './dto/request-register-user-info.dto';
import { ResponseUserInfoWithTokensDto } from './dto/response-user-info-with-tokens.dto';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UserStatus } from './user-status.enum';
import { kakaoUser } from 'src/auth/interfaces/kakao.user.interface';
import { ResponseOauthLoginDto } from 'src/auth/dto/response-oauth-login.dto';
import { ExceptionCode } from 'src/common/exceptions/exception-code.enum';
import { RequestUpdateHeightDto } from './dto/request-update.height.dto';
import { RequestUpdateWeightDto } from './dto/request-update.weight.dto';
import { ResponseSleepGoalDto } from './dto/response-sleep-goal.dto';

@Injectable()
export class UserService {
  private readonly logger = new Logger(UserService.name);
  private readonly accessTokenExpiresIn: string;
  private readonly refreshTokenExpiresIn: string;
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {
    this.accessTokenExpiresIn =
      this.configService.get<string>('ACCESS_TOKEN_EXPIRES_IN') || '1d';
    this.refreshTokenExpiresIn =
      this.configService.get<string>('REFRESH_TOKEN_EXPIRES_IN') || '7d';
  }

  // 사용자 정보 조회
  async getUserInfo(id: number): Promise<ResponseUserInfoDto> {
    this.logger.log(`사용자 정보 조회 시작 - userId: ${id}`);
    try {
      const user = await this.findById(id);
      const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
      this.logger.log(`사용자 정보 조회 성공 - userId: ${id}`);
      return responseUserInfoDto;
    } catch (error) {
      this.logger.error(`사용자 정보 조회 실패 - userId: ${id}`, error.stack);
      throw error;
    }
  }

  //사용자 임시 회원가입(authService에서 콜함)
  async createUserTemporary(
    kakaoUser: kakaoUser,
  ): Promise<ResponseOauthLoginDto> {
    this.logger.log(
      `임시 사용자 생성 시작 - provider: ${kakaoUser.provider}, id: ${kakaoUser.id}`,
    );
    try {
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
        status: newUser.status,
      };
      const accessToken = this.jwtService.sign(payload, {
        expiresIn: this.accessTokenExpiresIn,
      });
      const refreshToken = this.jwtService.sign(payload, {
        expiresIn: this.refreshTokenExpiresIn,
      });
      newUser.refresh_token = refreshToken;
      await this.userRepository.update(newUser.id, {
        refresh_token: refreshToken,
      });
      const dto: ResponseOauthLoginDto = ResponseOauthLoginDto.fromEntity(
        newUser,
        accessToken,
        refreshToken,
      );
      this.logger.log(`임시 사용자 생성 성공 - userId: ${newUser.id}`);
      return dto;
    } catch (error) {
      this.logger.error(
        `임시 사용자 생성 실패 - provider: ${kakaoUser.provider}, id: ${kakaoUser.id}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 이름 변경
  async updateName(
    id: number,
    firstName: string,
    lastName: string,
  ): Promise<ResponseUserInfoDto> {
    this.logger.log(
      `사용자 이름 변경 시작 - userId: ${id}, firstName: ${firstName}, lastName: ${lastName}`,
    );
    try {
      const user = await this.findById(id);
      user.first_name = firstName;
      user.last_name = lastName;
      await this.userRepository.update(user.id, {
        first_name: firstName,
        last_name: lastName,
      });
      const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
      this.logger.log(`사용자 이름 변경 성공 - userId: ${id}`);
      return responseUserInfoDto;
    } catch (error) {
      this.logger.error(`사용자 이름 변경 실패 - userId: ${id}`, error.stack);
      throw error;
    }
  }

  // 사용자 생년월일 변경
  async updateBirthdate(
    id: number,
    birthDate: Date,
  ): Promise<ResponseUserInfoDto> {
    this.logger.log(
      `사용자 생년월일 변경 시작 - userId: ${id}, birthDate: ${birthDate}`,
    );
    try {
      const user = await this.findById(id);
      user.birth_date = birthDate;
      await this.userRepository.update(user.id, {
        birth_date: birthDate,
      });
      const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
      this.logger.log(`사용자 생년월일 변경 성공 - userId: ${id}`);
      return responseUserInfoDto;
    } catch (error) {
      this.logger.error(
        `사용자 생년월일 변경 실패 - userId: ${id}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 성별 변경
  async updateGender(id: number, gender: string): Promise<ResponseUserInfoDto> {
    this.logger.log(`사용자 성별 변경 시작 - userId: ${id}, gender: ${gender}`);
    try {
      const user = await this.findById(id);
      user.gender = gender;
      await this.userRepository.update(user.id, {
        gender: gender,
      });
      const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
      this.logger.log(`사용자 성별 변경 성공 - userId: ${id}`);
      return responseUserInfoDto;
    } catch (error) {
      this.logger.error(`사용자 성별 변경 실패 - userId: ${id}`, error.stack);
      throw error;
    }
  }

  // 사용자 국적 변경
  async updateCountry(
    id: number,
    country: string,
  ): Promise<ResponseUserInfoDto> {
    this.logger.log(
      `사용자 국적 변경 시작 - userId: ${id}, country: ${country}`,
    );
    try {
      const user = await this.findById(id);
      user.nationality = country;
      await this.userRepository.update(user.id, {
        nationality: country,
      });
      const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
      this.logger.log(`사용자 국적 변경 성공 - userId: ${id}`);
      return responseUserInfoDto;
    } catch (error) {
      this.logger.error(`사용자 국적 변경 실패 - userId: ${id}`, error.stack);
      throw error;
    }
  }

  // 사용자 키 변경
  async updateHeight(
    id: number,
    dto: RequestUpdateHeightDto,
  ): Promise<ResponseUserInfoDto> {
    this.logger.log(
      `사용자 키 변경 시작 - userId: ${id}, height: ${dto.height}, unit: ${dto.lengthUnit}`,
    );
    try {
      const user = await this.findById(id);
      user.height = dto.height;
      user.length_unit = dto.lengthUnit;
      await this.userRepository.update(user.id, {
        height: dto.height,
        length_unit: dto.lengthUnit,
      });
      const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
      this.logger.log(`사용자 키 변경 성공 - userId: ${id}`);
      return responseUserInfoDto;
    } catch (error) {
      this.logger.error(`사용자 키 변경 실패 - userId: ${id}`, error.stack);
      throw error;
    }
  }

  // 사용자 몸무게 변경
  async updateWeight(
    id: number,
    dto: RequestUpdateWeightDto,
  ): Promise<ResponseUserInfoDto> {
    this.logger.log(
      `사용자 몸무게 변경 시작 - userId: ${id}, weight: ${dto.weight}, unit: ${dto.weightUnit}`,
    );
    try {
      const user = await this.findById(id);
      user.weight = dto.weight;
      user.weight_unit = dto.weightUnit;
      await this.userRepository.update(user.id, {
        weight: dto.weight,
        weight_unit: dto.weightUnit,
      });
      const responseUserInfoDto = ResponseUserInfoDto.fromEntity(user);
      this.logger.log(`사용자 몸무게 변경 성공 - userId: ${id}`);
      return responseUserInfoDto;
    } catch (error) {
      this.logger.error(`사용자 몸무게 변경 실패 - userId: ${id}`, error.stack);
      throw error;
    }
  }

  // 사용자 목표 수면 시간 변경
  async updateMinSleepDuration(
    id: number,
    minSleepDuration: string,
  ): Promise<ResponseUserInfoDto> {
    this.logger.log(
      `사용자 목표 수면시간 변경 시작 - userId: ${id}, duration: ${minSleepDuration}`,
    );
    try {
      const user = await this.findById(id);
      user.min_sleep_duration = minSleepDuration;
      await this.userRepository.update(user.id, {
        min_sleep_duration: minSleepDuration,
      });
      const updatedUser = await this.findById(id);
      const responseUserInfoDto = ResponseUserInfoDto.fromEntity(updatedUser);
      this.logger.log(`사용자 목표 수면시간 변경 성공 - userId: ${id}`);
      return responseUserInfoDto;
    } catch (error) {
      this.logger.error(
        `사용자 목표 수면시간 변경 실패 - userId: ${id}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 취침 시간 변경
  async updateSleepTime(
    id: number,
    sleepTime: string,
  ): Promise<ResponseUserInfoDto> {
    this.logger.log(
      `사용자 취침시간 변경 시작 - userId: ${id}, sleepTime: ${sleepTime}`,
    );
    try {
      const user = await this.findById(id);

      // sleepPreferences 초기화
      if (!user.sleepPreferences) {
        user.sleepPreferences = {
          targetSleepTime: user.sleep_time || '23:00', // getter 메서드 호출
          targetWakeTime: user.wake_time || '07:00', // getter 메서드 호출
          timezone: 'Asia/Seoul',
        };
        this.logger.debug(`sleepPreferences 초기화 - userId: ${id}`);
      }

      // 새 취침 시간 설정
      user.sleepPreferences.targetSleepTime = sleepTime;

      await this.userRepository.update(user.id, {
        sleep_time: sleepTime, // 이전 버전과의 호환성을 위해
        sleepPreferences: user.sleepPreferences,
      });

      const updatedUser = await this.findById(id);
      const responseUserInfoDto = ResponseUserInfoDto.fromEntity(updatedUser);
      this.logger.log(`사용자 취침시간 변경 성공 - userId: ${id}`);
      return responseUserInfoDto;
    } catch (error) {
      this.logger.error(
        `사용자 취침시간 변경 실패 - userId: ${id}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 기상 시간 변경
  async updateWakeTime(
    id: number,
    wakeTime: string,
  ): Promise<ResponseUserInfoDto> {
    this.logger.log(
      `사용자 기상시간 변경 시작 - userId: ${id}, wakeTime: ${wakeTime}`,
    );
    try {
      const user = await this.findById(id);

      // sleepPreferences 초기화
      if (!user.sleepPreferences) {
        user.sleepPreferences = {
          targetSleepTime: user.sleep_time || '22:00',
          targetWakeTime: user.wake_time || '07:00',
          timezone: 'Asia/Seoul',
        };
        this.logger.debug(`sleepPreferences 초기화 - userId: ${id}`);
      }

      // 새 기상 시간 설정
      user.sleepPreferences.targetWakeTime = wakeTime;

      await this.userRepository.update(user.id, {
        wake_time: wakeTime, // 이전 버전과의 호환성을 위해
        sleepPreferences: user.sleepPreferences,
      });

      const updatedUser = await this.findById(id);
      const responseUserInfoDto = ResponseUserInfoDto.fromEntity(updatedUser);
      this.logger.log(`사용자 기상시간 변경 성공 - userId: ${id}`);
      return responseUserInfoDto;
    } catch (error) {
      this.logger.error(
        `사용자 기상시간 변경 실패 - userId: ${id}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 초기 정보 등록
  async registerUserInfo(
    id: number,
    userInfo: RequestRegisterUserInfoDto,
  ): Promise<ResponseUserInfoDto> {
    this.logger.log(`사용자 초기 정보 등록 시작 - userId: ${id}`);
    try {
      const user = await this.findById(id);
      RequestRegisterUserInfoDto.toEntity(userInfo, user);

      //새롭게 JWT 토큰 발급
      const payload = {
        sub: user.id,
        email: user.email,
        status: user.status,
      };
      const accessToken = this.jwtService.sign(payload, {
        expiresIn: this.accessTokenExpiresIn,
      });
      const refreshToken = this.jwtService.sign(payload, {
        expiresIn: this.refreshTokenExpiresIn,
      });
      user.refresh_token = refreshToken;
      const updatedUser = await this.userRepository.save(user);
      const responseUserInfoWithTokensDto =
        ResponseUserInfoWithTokensDto.fromEntity(
          updatedUser,
          accessToken,
          refreshToken,
        );
      this.logger.log(`사용자 초기 정보 등록 성공 - userId: ${id}`);
      return responseUserInfoWithTokensDto;
    } catch (error) {
      this.logger.error(
        `사용자 초기 정보 등록 실패 - userId: ${id}`,
        error.stack,
      );
      throw error;
    }
  }

  // userId로 사용자 조회
  public async findById(id: number): Promise<User> {
    this.logger.debug(`ID로 사용자 조회 - userId: ${id}`);
    try {
      const user = await this.userRepository.findOneBy({ id });
      if (!user) {
        this.logger.warn(`사용자 없음 - userId: ${id}`);
        throwNotFoundException(ExceptionCode.USER_NOT_FOUND);
      }
      return user;
    } catch (error) {
      this.logger.error(`ID로 사용자 조회 실패 - userId: ${id}`, error.stack);
      throw error;
    }
  }

  //사용자 로그아웃
  async logout(userId: number) {
    this.logger.log(`사용자 로그아웃 시작 - userId: ${userId}`);
    try {
      const user = await this.findById(userId);
      //refresh_Token ''으로 수정
      await this.userRepository.update(userId, { refresh_token: '' });
      this.logger.log(`사용자 로그아웃 성공 - userId: ${userId}`);
    } catch (error) {
      this.logger.error(
        `사용자 로그아웃 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  //사용자 탈퇴
  async withdraw(userId: number) {
    this.logger.log(`사용자 탈퇴 시작 - userId: ${userId}`);
    try {
      const user = await this.findById(userId);
      //refresh_Token ''으로 수정
      this.userRepository.update(userId, {
        refresh_token: '',
        status: UserStatus.PENDING_WITHDRAW,
        withdrawal_at: new Date(),
      });
      this.logger.log(`사용자 탈퇴 성공 - userId: ${userId}`);
    } catch (error) {
      this.logger.error(`사용자 탈퇴 실패 - userId: ${userId}`, error.stack);
      throw error;
    }
  }

  // 탈퇴 보류 회원 복구
  async reinstate(userId: number) {
    this.logger.log(`탈퇴 회원 복구 시작 - userId: ${userId}`);
    try {
      const user = await this.findById(userId);
      if (user.status !== UserStatus.WITHDRAWN) {
        this.logger.warn(
          `탈퇴 상태가 아닌 사용자 - userId: ${userId}, status: ${user.status}`,
        );
        throw new Error('이미 활성화된 계정입니다.');
      }
      //새롭게 JWT 토큰 발급
      const payload = {
        sub: user.id,
        email: user.email,
        status: user.status,
      };
      const accessToken = this.jwtService.sign(payload, {
        expiresIn: this.accessTokenExpiresIn,
      });
      const refreshToken = this.jwtService.sign(payload, {
        expiresIn: this.refreshTokenExpiresIn,
      });
      this.userRepository.update(userId, {
        status: UserStatus.ACTIVE,
        refresh_token: refreshToken,
        withdrawal_at: null,
      });
      const responseUserInfoWithTokensDto =
        ResponseUserInfoWithTokensDto.fromEntity(
          user,
          accessToken,
          refreshToken,
        );
      this.logger.log(`탈퇴 회원 복구 성공 - userId: ${userId}`);
      return responseUserInfoWithTokensDto;
    } catch (error) {
      this.logger.error(`탈퇴 회원 복구 실패 - userId: ${userId}`, error.stack);
      throw error;
    }
  }

  async getSleepGoal(userId: number): Promise<ResponseSleepGoalDto> {
    this.logger.log(`수면 목표 조회 시작 - userId: ${userId}`);
    try {
      const user = await this.findById(userId);
      if (!user) {
        this.logger.warn(`사용자 없음 - userId: ${userId}`);
        throwNotFoundException(ExceptionCode.USER_NOT_FOUND);
      }
      const dto = ResponseSleepGoalDto.fromEntity(user);
      this.logger.log(`수면 목표 조회 성공 - userId: ${userId}`);
      return dto;
    } catch (error) {
      this.logger.error(`수면 목표 조회 실패 - userId: ${userId}`, error.stack);
      throw error;
    }
  }
}
