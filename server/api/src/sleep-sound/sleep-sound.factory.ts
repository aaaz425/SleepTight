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
    startTime: Date;
  }): SleepSound {
    const { reportId, segmentId, fileUrl, duration, startTime } = params;

    return this.sleepSoundRepo.create({
      sleepReport: reportId,
      segmentId,
      voiceUrl: fileUrl,
      duration,
      startTime,
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

  // SleepSound와 SleepReport 조인을 통해 reportId에 연결된 sleepSound만 가져오도록 필터링
  async findByReportIdWithQueryBuilder(
    reportId: number,
  ): Promise<SleepSound[]> {
    return this.sleepSoundRepo
      .createQueryBuilder('sound')
      .leftJoin('sound.sleepReport', 'report')
      .where('report.id = :reportId', { reportId })
      .getMany();
  }

  async findWithEventsByReportId(reportId: number): Promise<SleepSound[]> {
    return this.sleepSoundRepo
      .createQueryBuilder('sound')
      .leftJoin('sound.sleepReport', 'report')
      .leftJoinAndMapMany(
        'sound.events', // sound에 가상 필드로 매핑
        SleepEvent,
        'event',
        'event.segmentId = sound.segmentId',
      )
      .where('report.id = :reportId', { reportId })
      .getMany();
  }

  // reportId로 sleepSound 목록 가져오기
  async findByReportId(
    reportId: number,
    manager?: EntityManager,
  ): Promise<SleepSound[]> {
    const usedManager = manager ?? this.sleepSoundRepo.manager;
    return usedManager.find(SleepSound, { where: { sleepReport: reportId } });
  }

  // segmentId 목록으로 이벤트들 가져오기
  async findEventsBySegmentIds(segmentIds: string[], manager: EntityManager) {
    return manager.find(SleepEvent, {
      where: { segmentId: In(segmentIds) },
    });
  }

  getManager(): EntityManager {
    return this.sleepSoundRepo.manager;
  }
}
