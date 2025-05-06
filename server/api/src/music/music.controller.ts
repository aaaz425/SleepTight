import { Controller, Get, Param, Req, UseGuards } from "@nestjs/common";
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
    async getMusicInfo(@Req() req, @Param("musicId") musicId :number) :Promise<ResponseMusicDto>{
        const userId :number =  req.user.id??-1;
        const ResponseMusicDto :ResponseMusicDto = await this.musicService.getMusicInfo(musicId, userId);
        return ResponseMusicDto;
    }
}