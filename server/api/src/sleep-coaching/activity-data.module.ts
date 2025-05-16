import { Module } from '@nestjs/common';
import { ActivityDataController } from './activity-data.controller';
import { ActivityDataService } from './activity-data.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ActivityData } from './entities/activity-data.entity';
import { SleepReport } from 'src/sleep-reports/entities/sleep-report.entity';

@Module({
  imports: [TypeOrmModule.forFeature([ActivityData, SleepReport])],
  controllers: [ActivityDataController],
  providers: [ActivityDataService],
})
export class SleepCoachingModule {}
