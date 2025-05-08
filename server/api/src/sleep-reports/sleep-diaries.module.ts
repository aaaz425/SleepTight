import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SleepDiary } from './entities/sleep-diary.entity';
import { SleepReport } from './entities/sleep-report.entity';
import { SleepDiariesService } from './sleep-diaries.service';
import { SleepDiariesController } from './sleep-diaries.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([SleepDiary, SleepReport]),
  ],
  providers: [SleepDiariesService],
  controllers: [SleepDiariesController],
})
export class SleepDiariesModule {}
