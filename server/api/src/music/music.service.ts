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
    if (!music) {
      throwNotFoundException('음악 정보를 찾을 수 없습니다.','MUSIC_NOT_FOUND');
    }
    const responseMusicDto = ResponseMusicDto.fromEntity(music, userId);
    return responseMusicDto;
  }

  async getAllMusic(category :string, userId :number): Promise<ResponseMusicDto[]> {
    let musicList :Music[];
    if (!category || category === undefined || category === null) { // 카테고리가 없는 경우
        musicList = await this.musicRepository.find();
    } else { // 카테고리가 있으면 해당 카테고리의 음악만 가져옴
        musicList = await this.musicRepository.findBy({ category });
    }
    return musicList.map((music) => ResponseMusicDto.fromEntity(music, userId));
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