import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SleepReport } from './entities/sleep-report.entity';
import { SleepReportController } from './sleep-report.controller';
import { SleepReportService } from './sleep-report.service';
import { SleepSoundModule } from 'src/sleep-sound/sleep-sound.module';
import { SleepStageService } from './sleep-stage.service';
import { SleepStageFactory } from './sleep-stage.factory';
import { SleepStageLog } from './entities/sleep-stage-log.entity';
import { User } from 'src/users/entities/user.entity';
import { SleepReportFactory } from './sleep-report.factory';

@Module({
  imports: [
    TypeOrmModule.forFeature([SleepReport, User, SleepStageLog]),
    SleepSoundModule,
  ],
  controllers: [SleepReportController],
  providers: [
    SleepReportService,
    SleepStageService,
    SleepStageFactory,
    SleepReportFactory,
  ],
  exports: [SleepStageService],
})
export class SleepReportModule {}
