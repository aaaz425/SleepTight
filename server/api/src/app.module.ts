import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserModule } from './users/user.module';
import { AuthModule } from './auth/auth.module';
import { Music } from './music/music.entity';
import { MusicModule } from './music/music.module';
import { HealthModule } from './health/health.module';
import { ScheduleModule } from '@nestjs/schedule';
import { TaskModule } from './task/task.module';
import { SleepSoundModule } from './sleep-sound/sleep-sound.module';
import { SleepReportModule } from './sleep-reports/sleep-report.module';
import { SleepDiariesModule } from './sleep-reports/sleep-diaries.module';
import { SleepCoachingModule } from './sleep-coaching/sleep-coaching.module';

@Module({
  imports: [
    TaskModule,
    ScheduleModule.forRoot(),
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('DB_HOST'),
        port: configService.get<number>('DB_PORT'),
        username: configService.get<string>('DB_USERNAME'),
        password: configService.get<string>('DB_PASSWORD'),
        database: configService.get<string>('DB_DATABASE'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: true, // 개발 환경만 true
        logging: false,
      }),
    }),
    UserModule,
    SleepReportModule,
    SleepDiariesModule,
    SleepSoundModule,
    AuthModule,
    MusicModule,
    HealthModule,
    SleepCoachingModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
