// src/user/user.controller.ts
import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Patch,
  UseGuards,
  Request,
  HttpCode,
  Logger,
} from '@nestjs/common';
import { UserService } from './user.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { ResponseUserInfoDto } from './dto/response-user-info.dto';
import { RequestRegisterUserInfoDto } from './dto/request-register-user-info.dto';
import { ResponseUserInfoWithTokensDto } from './dto/response-user-info-with-tokens.dto';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiProperty,
  ApiTags,
} from '@nestjs/swagger';
import { RequestUpdateHeightDto } from './dto/request-update.height.dto';
import { RequestUpdateWeightDto } from './dto/request-update.weight.dto';
import { RequestUpdateNameDto } from './dto/request-update-name.dto';
import { RequestUpdateBirthDateDto } from './dto/request-update-birth-date.dto';

@ApiTags('USERS')
@Controller('user')
export class UserController {
  private readonly logger = new Logger(UserController.name);

  constructor(private readonly userService: UserService) {}

  // 사용자 정보 조회
  @ApiOperation({ summary: '유저 정보 조회' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Get()
  async getUserInfo(@Request() req): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(`사용자 정보 조회 요청 - userId: ${userId}`);
    try {
      const result = await this.userService.getUserInfo(userId);
      return result;
    } catch (error) {
      this.logger.error(
        `사용자 정보 조회 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 이름 변경
  @ApiOperation({ summary: '유저 이름 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('name')
  async updateName(
    @Request() req,
    @Body() dto: RequestUpdateNameDto,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(
      `사용자 이름 변경 요청 - userId: ${userId}, firstName: ${dto.firstName}, lastName: ${dto.lastName}`,
    );
    try {
      const result = await this.userService.updateName(
        userId,
        dto.firstName,
        dto.lastName,
      );
      return result;
    } catch (error) {
      this.logger.error(
        `사용자 이름 변경 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 생년월일 변경
  @ApiOperation({ summary: '유저 생년월일 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('birth-date')
  async updateBirthDate(
    @Request() req,
    @Body() requestDto: RequestUpdateBirthDateDto,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(
      `사용자 생년월일 변경 요청 - userId: ${userId}, birthDate: ${requestDto.birthDate}`,
    );
    try {
      const result = await this.userService.updateBirthdate(
        userId,
        requestDto.birthDate,
      );
      return result;
    } catch (error) {
      this.logger.error(
        `사용자 생년월일 변경 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 성별 변경
  @ApiOperation({ summary: '유저 성별 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('gender')
  async updateGender(
    @Request() req,
    @Body('gender') gender: string,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(
      `사용자 성별 변경 요청 - userId: ${userId}, gender: ${gender}`,
    );
    try {
      const result = await this.userService.updateGender(userId, gender);
      return result;
    } catch (error) {
      this.logger.error(
        `사용자 성별 변경 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 국적 변경
  @ApiOperation({ summary: '유저 국적 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('country')
  async updateCountry(
    @Request() req,
    @Body('country') country: string,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(
      `사용자 국적 변경 요청 - userId: ${userId}, country: ${country}`,
    );
    try {
      const result = await this.userService.updateCountry(userId, country);
      return result;
    } catch (error) {
      this.logger.error(
        `사용자 국적 변경 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 키 변경
  @ApiOperation({ summary: '유저저 키 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('height')
  async updateHeight(
    @Request() req,
    @Body() dto: RequestUpdateHeightDto,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(
      `사용자 키 변경 요청 - userId: ${userId}, height: ${dto.height}, unit: ${dto.lengthUnit}`,
    );
    try {
      const result = await this.userService.updateHeight(userId, dto);
      return result;
    } catch (error) {
      this.logger.error(`사용자 키 변경 실패 - userId: ${userId}`, error.stack);
      throw error;
    }
  }

  // 사용자 몸무게 변경
  @ApiOperation({ summary: '유저 몸무게 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('weight')
  async updateWeight(
    @Request() req,
    @Body() dto: RequestUpdateWeightDto,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(
      `사용자 몸무게 변경 요청 - userId: ${userId}, weight: ${dto.weight}, unit: ${dto.weightUnit}`,
    );
    try {
      const result = await this.userService.updateWeight(userId, dto);
      return result;
    } catch (error) {
      this.logger.error(
        `사용자 몸무게 변경 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 목표 수면 시간 변경
  @ApiOperation({ summary: '유저 목표 수면시간 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('min-sleep-duration')
  async updateMinSleepDuration(
    @Request() req,
    @Body('min_sleep_duration') minSleepDuration: string,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(
      `사용자 목표 수면시간 변경 요청 - userId: ${userId}, duration: ${minSleepDuration}`,
    );
    try {
      const result = await this.userService.updateMinSleepDuration(
        userId,
        minSleepDuration,
      );
      return result;
    } catch (error) {
      this.logger.error(
        `사용자 목표 수면시간 변경 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 취침 시간 변경
  @ApiOperation({ summary: '유저 취침시간 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('sleep-time')
  async updateSleepTime(
    @Request() req,
    @Body('sleep_time') sleepTime: string,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(
      `사용자 취침시간 변경 요청 - userId: ${userId}, sleepTime: ${sleepTime}`,
    );
    try {
      const result = await this.userService.updateSleepTime(userId, sleepTime);
      return result;
    } catch (error) {
      this.logger.error(
        `사용자 취침시간 변경 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 사용자 기상 시간 변경
  @ApiOperation({ summary: '유저 기상시간간 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('wake-time')
  async updateWakeTime(
    @Request() req,
    @Body('wake_time') wakeTime: string,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(
      `사용자 기상시간 변경 요청 - userId: ${userId}, wakeTime: ${wakeTime}`,
    );
    try {
      const result = await this.userService.updateWakeTime(userId, wakeTime);
      return result;
    } catch (error) {
      this.logger.error(
        `사용자 기상시간 변경 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 초기 사용자 정보 등록
  @ApiOperation({ summary: '유저 초기 정보 등록' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Post('/register')
  async registerUserInfo(
    @Request() req,
    @Body() RequestRegisterUserInfoDto: RequestRegisterUserInfoDto,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    this.logger.log(`사용자 초기 정보 등록 요청 - userId: ${userId}`);
    try {
      const result = await this.userService.registerUserInfo(
        userId,
        RequestRegisterUserInfoDto,
      );
      return result;
    } catch (error) {
      this.logger.error(
        `사용자 초기 정보 등록 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 로그아웃
  @ApiOperation({ summary: '로그아웃' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Post('logout')
  async logout(@Request() req) {
    const userId: number = req.user.userId;
    this.logger.log(`사용자 로그아웃 요청 - userId: ${userId}`);
    try {
      await this.userService.logout(userId);
    } catch (error) {
      this.logger.error(
        `사용자 로그아웃 실패 - userId: ${userId}`,
        error.stack,
      );
      throw error;
    }
  }

  // 회원 탈퇴
  @ApiOperation({ summary: '회원 탈퇴' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('withdraw')
  async withdraw(@Request() req) {
    const userId: number = req.user.userId;
    this.logger.log(`회원 탈퇴 요청 - userId: ${userId}`);
    try {
      await this.userService.withdraw(userId);
    } catch (error) {
      this.logger.error(`회원 탈퇴 실패 - userId: ${userId}`, error.stack);
      throw error;
    }
  }

  // 회원 복구
  @ApiOperation({ summary: '탈퇴 회원 복구' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('reinstate')
  async reinstate(@Request() req): Promise<ResponseUserInfoWithTokensDto> {
    const userId: number = req.user.userId;
    this.logger.log(`탈퇴 회원 복구 요청 - userId: ${userId}`);
    try {
      const result = await this.userService.reinstate(userId);
      return result;
    } catch (error) {
      this.logger.error(`탈퇴 회원 복구 실패 - userId: ${userId}`, error.stack);
      throw error;
    }
  }

  //수면 목표 조회
  @ApiOperation({ summary: '수면 목표 조회' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Get('sleep-goal')
  async getSleepGoal(@Request() req) {
    const userId: number = req.user.userId;
    this.logger.log(`수면 목표 조회 요청 - userId: ${userId}`);
    try {
      const result = await this.userService.getSleepGoal(userId);
      return result;
    } catch (error) {
      this.logger.error(`수면 목표 조회 실패 - userId: ${userId}`, error.stack);
      throw error;
    }
  }
}
