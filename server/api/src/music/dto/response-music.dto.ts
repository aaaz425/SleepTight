import { Music } from "../music.entity";

export class ResponseMusicDto {
    id: number;
    title: string;
    category: string;
    coverUrl?: string;
    isLiked: boolean;
    likeCount?: number;
    streamUrl: string;

    static fromEntity(music: Music, userId: number): ResponseMusicDto {
        const responseMusicDto = new ResponseMusicDto();
        responseMusicDto.id = music.id;
        responseMusicDto.title = music.musicTitle;
        responseMusicDto.category = music.category??'Unknown';
        responseMusicDto.coverUrl = music.musicCoverImg;
        responseMusicDto.isLiked = music.userList?.includes(userId) || false;
        responseMusicDto.likeCount = music.musicLikesCount??0;
        responseMusicDto.streamUrl = music.musicStreamUrl;
        return responseMusicDto;
    }
}