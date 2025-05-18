// src/user/user.controller.ts
import { Controller, Get, Post, Body, Param, Patch, UseGuards, Request, HttpCode } from '@nestjs/common';
import { UserService } from './user.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { ResponseUserInfoDto } from './dto/response-user-info.dto';
import { RequestRegisterUserInfoDto } from './dto/request-register-user-info.dto';
import { ResponseUserInfoWithTokensDto } from './dto/response-user-info-with-tokens.dto';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { RequestUpdateHeightDto } from './dto/request.update.height.dto';
import { RequestUpdateWeightDto } from './dto/request.update.weight.dto';

@ApiTags('USERS')
@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) { }

  // 사용자 정보 조회
  @ApiOperation({ summary: '유저 정보 조회' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Get()
  async getUserInfo(@Request() req): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.getUserInfo(userId);
  }

  // 사용자 이름 변경
  @ApiOperation({ summary: '유저 이름 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('name')
  async updateName(
    @Request() req,
    @Body('firstName') firstName: string,
    @Body('lastName') lastName: string,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateName(userId, firstName, lastName);
  }

  // 사용자 생년월일 변경
  @ApiOperation({ summary: '유저 생년월일 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('birth-date')
  async updateBirthDate(
    @Request() req,
    @Body('birthDate') birthDate: Date,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateBirthdate(userId, birthDate);
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
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateGender(userId, gender);
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
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateCountry(userId, country);
  }

  // 사용자 키 변경
  @ApiOperation({ summary: '유저저 키 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('height')
  async updateHeight(
    @Request() req,
    @Body() dto :RequestUpdateHeightDto,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateHeight(userId, dto);
  }

  // 사용자 몸무게 변경
  @ApiOperation({ summary: '유저 몸무게 변경' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('weight')
  async updateWeight(
    @Request() req,
    @Body() dto :RequestUpdateWeightDto): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateWeight(userId, dto);
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
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateMinSleepDuration(userId, minSleepDuration);
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
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateSleepTime(userId, sleepTime);
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
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateWakeTime(userId, wakeTime);
  }

  // 초기 사용자 정보 등록
  @ApiOperation({ summary: '유저 초기 정보 등록' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Post('/register')
  async registerUserInfo(
    @Request() req,
    @Body() RequestRegisterUserInfoDto: RequestRegisterUserInfoDto,
  ) :Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    return this.userService.registerUserInfo(userId, RequestRegisterUserInfoDto);
  }

  // 로그아웃
  @ApiOperation({ summary: '로그아웃' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Get('logout')
  async logout(@Request() req) {
    const userId :number = req.user.userId;
    this.userService.logout(userId);
  }

  // 회원 탈퇴
  @ApiOperation({ summary: '회원 탈퇴' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('withdraw')
  async withdraw(@Request() req) {
    const userId :number = req.user.userId;
    this.userService.withdraw(userId);
  }

  // 회원 복구
  @ApiOperation({ summary: '탈퇴 회원 복구' })
  @ApiBearerAuth() // JWT 인증 필요
  @UseGuards(JwtAuthGuard)
  @Patch('reinstate')
  async reinstate(@Request() req) :Promise<ResponseUserInfoWithTokensDto> {
    const userId :number = req.user.userId;
    return this.userService.reinstate(userId);
  }
}