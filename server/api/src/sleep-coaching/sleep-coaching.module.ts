import { Module } from '@nestjs/common';
import { ActivityDataController } from './activity-data.controller';
import { ActivityDataService } from './activity-data.service';
import { SleepCoachingController } from './sleep-coaching.controller';
import { SleepCoachingService } from './sleep-coaching.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ActivityData } from './entities/activity-data.entity';
import { SleepReport } from 'src/sleep-reports/entities/sleep-report.entity';
import { SleepDiary } from 'src/sleep-reports/entities/sleep-diary.entity';
import { SleepCoaching } from './entities/sleep-coaching.entity';

@Module({

  imports: [
    TypeOrmModule.forFeature([ActivityData, SleepReport, SleepDiary, SleepCoaching]),
  ],
  controllers: [ActivityDataController, SleepCoachingController],
  providers: [ActivityDataService, SleepCoachingService],
})
export class SleepCoachingModule {}
