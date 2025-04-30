// src/user/user.controller.ts
import { Controller, Get, Post, Body, Param, Patch } from '@nestjs/common';
import { User } from './entities/user.entity';
import {UserService} from './user.service';


@Controller('api/user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  // 사용자 이름 변경
  //TODO: Header에 있는 Token으로 user_id 가져오기
  @Patch('name/:id')
  async updateName(@Param('id') id: number, @Body() name: string): Promise<User> {
    return this.userService.updateName(id, name);
  }
}