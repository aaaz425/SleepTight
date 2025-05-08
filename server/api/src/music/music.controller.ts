import { Controller, Get, Param, Query, Request, UseGuards } from "@nestjs/common";
import { MusicService } from "./music.service";
import { ResponseMusicDto } from "./dto/response-music.dto";
import { JwtAuthGuard } from "src/auth/jwt-auth.guard";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags('MUSIC')
@Controller('music')
export class MusicController {
    constructor(
        private readonly musicService: MusicService,
    ) {}

    @ApiOperation({ summary: '특정 음악 정보 조회' })
    @ApiBearerAuth() // JWT 인증 필요
    @UseGuards(JwtAuthGuard)
    @Get(":musicId")
    async getMusicInfo(@Request() req, @Param("musicId") musicId :number) :Promise<ResponseMusicDto>{
        const userId :number =  req.user.userId;
        const ResponseMusicDto :ResponseMusicDto = await this.musicService.getMusicInfo(musicId, userId);
        return ResponseMusicDto;
    }

    @ApiOperation({ summary: '카테고리에 맞는 음악조회(없으면 전체)' })
    @ApiBearerAuth() // JWT 인증 필요
    @UseGuards(JwtAuthGuard)
    @Get()
    async getAllMusic(@Request() req, @Query("category") category: string) :Promise<any>{
        const userId :number =  req.user.userId;
        const musicList :ResponseMusicDto[] = await this.musicService.getAllMusic(category, userId);
        return { musicList : musicList,};
    }
}