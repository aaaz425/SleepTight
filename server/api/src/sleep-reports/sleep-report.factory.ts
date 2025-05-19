// sleep-report.factory.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SleepReport } from './entities/sleep-report.entity';

@Injectable()
export class SleepReportFactory {
  constructor(
    @InjectRepository(SleepReport)
    private readonly reportRepo: Repository<SleepReport>,
  ) {}

  createNew(
    userId: number,
    sleepStartTime: Date,
    sleepDate: Date,
  ): SleepReport {
    return this.reportRepo.create({
      userId,
      sleepStartTime,
      sleepDate,
    });
  }

  async save(report: SleepReport): Promise<SleepReport> {
    return await this.reportRepo.save(report);
  }
}
