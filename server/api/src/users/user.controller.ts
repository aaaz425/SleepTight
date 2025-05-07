// src/user/user.controller.ts
import { Controller, Get, Post, Body, Param, Patch, UseGuards, Request, HttpCode } from '@nestjs/common';
import { User } from './entities/user.entity';
import { UserService } from './user.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { ResponseUserInfoDto } from './dto/response-user-info.dto';
import { request } from 'http';
import { RequestRegisterUserInfoDto } from './dto/request-register-user-info.dto';


@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) { }

  // 사용자 정보 조회
  @UseGuards(JwtAuthGuard)
  @Get()
  async getUserInfo(@Request() req): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.getUserInfo(userId);
  }

  // 사용자 이름 변경
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
  @UseGuards(JwtAuthGuard)
  @Patch('birthDate')
  async updateBirthDate(
    @Request() req,
    @Body('birthDate') birthDate: Date,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateBirthdate(userId, birthDate);
  }

  // 사용자 성별 변경
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
  @UseGuards(JwtAuthGuard)
  @Patch('height')
  async updateHeight(
    @Request() req,
    @Body('height') height: number,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateHeight(userId, height);
  }

  // 사용자 몸무게 변경
  @UseGuards(JwtAuthGuard)
  @Patch('weight')
  async updateWeight(
    @Request() req,
    @Body('weight') weight: number,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateWeight(userId, weight);
  }

  // 사용자 목표 수면 시간 변경
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
  @UseGuards(JwtAuthGuard)
  @Patch('wake-time')
  async updateWakeTime(
    @Request() req,
    @Body('wake_time') wakeTime: string,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateWakeTime(userId, wakeTime);
  }

  //초기 사용자 정보 등록
  @UseGuards(JwtAuthGuard)
  @Post('/register')
  async registerUserInfo(
    @Request() req,
    @Body() RequestRegisterUserInfoDto: RequestRegisterUserInfoDto,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId; // JWT에서 userId를 가져옴
    console.log('userId', userId);
    console.log('RequestRegisterUserInfoDto', RequestRegisterUserInfoDto);
    return this.userService.registerUserInfo(userId, RequestRegisterUserInfoDto);
  }

  //로그아웃
  @UseGuards(JwtAuthGuard)
  @Get('logout')
  async logout(@Request() req) {
    const userId :number = req.user.userId;
    this.userService.logout(userId);
  }

  //회원탈퇴
  @UseGuards(JwtAuthGuard)
  @Patch('withdraw')
  async withdraw(@Request() req) {
    const userId :number = req.user.userId;
    this.userService.withdraw(userId);
  }
}