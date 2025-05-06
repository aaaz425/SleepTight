import { Controller, Get, Param, Query, Request, UseGuards } from "@nestjs/common";
import { MusicService } from "./music.service";
import { ResponseMusicDto } from "./dto/response-music.dto";
import { JwtAuthGuard } from "src/auth/jwt-auth.guard";

@Controller('music')
export class MusicController {
    constructor(
        private readonly musicService: MusicService,
    ) {}

    @UseGuards(JwtAuthGuard)
    @Get(":musicId")
    async getMusicInfo(@Request() req, @Param("musicId") musicId :number) :Promise<ResponseMusicDto>{
        const userId :number =  req.user.userId;
        const ResponseMusicDto :ResponseMusicDto = await this.musicService.getMusicInfo(musicId, userId);
        return ResponseMusicDto;
    }

    @UseGuards(JwtAuthGuard)
    @Get()
    async getAllMusic(@Request() req, @Query("category") category: string) :Promise<any>{
        const userId :number =  req.user.userId;
        const musicList :ResponseMusicDto[] = await this.musicService.getAllMusic(category, userId);
        return { musicList : musicList,};
    }
}