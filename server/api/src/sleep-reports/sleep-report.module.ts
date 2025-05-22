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
import { SleepDiariesModule } from './sleep-diaries.module';
import { SleepSoundFactory } from 'src/sleep-sound/sleep-sound.factory';
import { SleepSound } from 'src/sleep-sound/entities/sleep-sound.entity';
import { SleepEvent } from 'src/sleep-sound/entities/sleep-event.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      SleepReport,
      User,
      SleepStageLog,
      SleepSound,
      SleepEvent,
    ]),
    SleepSoundModule,
    SleepDiariesModule,
  ],
  controllers: [SleepReportController],
  providers: [
    SleepReportService,
    SleepStageService,
    SleepStageFactory,
    SleepSoundFactory,
    SleepReportFactory,
  ],
  exports: [SleepStageService, SleepReportService],
})
export class SleepReportModule {}
