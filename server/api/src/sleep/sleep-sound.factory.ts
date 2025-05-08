// sleep-sound.factory.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SleepSound } from './entities/sleep-sound.entity';

@Injectable()
export class SleepSoundFactory {
  constructor(
    @InjectRepository(SleepSound)
    private readonly sleepSoundRepo: Repository<SleepSound>,
  ) {}

  create(params: {
    reportId: number;
    segmentId: string;
    fileUrl: string;
    duration: number;
  }): SleepSound {
    const { reportId, segmentId, fileUrl, duration } = params;

    return this.sleepSoundRepo.create({
      sleepReport: { id: reportId },
      segmentId,
      voiceUrl: fileUrl,
      duration,
    });
  }

  save(entity: SleepSound): Promise<SleepSound> {
    return this.sleepSoundRepo.save(entity);
  }

  // UUID 중복 확인
  async exist(options: { where: { segmentId: string } }): Promise<boolean> {
    const count = await this.sleepSoundRepo.count(options);
    return count > 0;
  }
}
