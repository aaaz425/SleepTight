// sleep-sound.factory.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { EntityManager, In, Repository } from 'typeorm';
import { SleepSound } from './entities/sleep-sound.entity';
import { SleepEvent } from './entities/sleep-event.entity';

@Injectable()
export class SleepSoundFactory {
  constructor(
    @InjectRepository(SleepSound)
    private readonly sleepSoundRepo: Repository<SleepSound>,
    @InjectRepository(SleepEvent)
    private readonly sleepEventRepo: Repository<SleepEvent>,
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
    const result = await this.sleepSoundRepo.findOne(options);
    return !!result;
  }

  async saveSleepEvent(sleepEvent: SleepEvent) {
    return this.sleepEventRepo.save(sleepEvent);
  }

  // reportId로 sleepSound 목록 가져오기
  async findByReportId(
    reportId: number,
    manager: EntityManager,
  ): Promise<SleepSound[]> {
    return manager.find(SleepSound, {
      where: { sleepReport: { id: reportId } },
    });
  }

  // segmentId 목록으로 이벤트들 가져오기
  async findEventsBySegmentIds(segmentIds: string[], manager: EntityManager) {
    return manager.find(SleepEvent, {
      where: { segmentId: In(segmentIds) },
    });
  }
}
