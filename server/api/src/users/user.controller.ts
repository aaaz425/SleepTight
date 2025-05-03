// src/user/user.controller.ts
import { Controller, Get, Post, Body, Param, Patch, UseGuards, Request, HttpCode } from '@nestjs/common';
import { User } from './entities/user.entity';
import {UserService} from './user.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { ResponseUserInfoDto } from './dto/response-userInfo.dto';


@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  // 사용자 정보 조회
  @UseGuards(JwtAuthGuard)
  @Get()
  async getUserInfo(@Request() req): Promise<ResponseUserInfoDto>{
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.getUserInfo(userId);
  }

  // 사용자 이름 변경
  @UseGuards(JwtAuthGuard)
  @Patch('name')
  async updateName(
    @Request() req,
    @Body('firstName') firstName :string,
    @Body('lastName') lastName :string,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateName(userId, firstName, lastName);
  }

  @UseGuards(JwtAuthGuard)
  @Patch('birthDate')
  async updateBirthDate(
    @Request() req,
    @Body('birthDate') birthDate :Date,
  ): Promise<ResponseUserInfoDto> {
    const userId = req.user.userId // JWT에서 userId를 가져옴
    return this.userService.updateBirthdate(userId, birthDate);
  }

}