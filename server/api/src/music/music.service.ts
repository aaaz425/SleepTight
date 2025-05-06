import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Music } from "./music.entity";
import { ResponseMusicDto } from "./dto/response-music.dto";
import { throwNotFoundException } from "src/common/exceptions/error.helper";

@Injectable()
export class MusicService {
  constructor(
    @InjectRepository(Music)
    private musicRepository: Repository<Music>,
  ) {}

  async getMusicInfo(musicId :number, userId :number): Promise<ResponseMusicDto> {
    const music = await this.musicRepository.findOneBy({ id: musicId });
    console.log("userId", userId);
    if (!music) {
      throwNotFoundException('음악 정보를 찾을 수 없습니다.','MUSIC_NOT_FOUND');
    }
    const responseMusicDto = ResponseMusicDto.fromEntity(music, userId);
    console.log("isLike?? : ", music.userList?.includes(userId));
    return responseMusicDto;
  }

  async findAll(): Promise<Music[]> {
    return this.musicRepository.find();
  }

  async findOne(id: number): Promise<Music> {
    const music = await this.musicRepository.findOneBy({ id });
    if (!music) {
      throw new Error(`Music with id ${id} not found`);
    }
    return music;
  }

  async create(music: Music): Promise<Music> {
    return this.musicRepository.save(music);
  }

  async update(id: number, music: Music): Promise<Music> {
    await this.musicRepository.update(id, music);
    return this.findOne(id);
  }
}