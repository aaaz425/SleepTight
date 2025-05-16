import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Between, Repository } from "typeorm";
import { ActivityData } from "./entities/activity-data.entity";
import { throwNotFoundException } from "src/common/exceptions/exception.helper";
import { ExceptionCode } from "src/common/exceptions/exception-code.enum";
import { SleepReport } from "src/sleep-reports/entities/sleep-report.entity";
import { ActiveTime } from "./interfaces/active-time.interface";
import { SleepTime } from "./interfaces/sleep-time.interface";
import { SleepDiary } from "src/sleep-reports/entities/sleep-diary.entity";
import axios from "axios";

@Injectable()
export class SleepCoachingService {
    constructor(
        @InjectRepository(ActivityData)
        private readonly activityDataRepository: Repository<ActivityData>,
        @InjectRepository(SleepReport)
        private readonly sleepReportRepository: Repository<SleepReport>,
        @InjectRepository(SleepDiary)
        private readonly sleepDiaryRepository: Repository<SleepDiary>,
    ) {}

    async getSleepCoaching(userId: number, sleepReportId :number): Promise<any> {
        const sleepReport: SleepReport | null = await this.sleepReportRepository.findOneBy({id : sleepReportId});
        if(!sleepReport) {
            throwNotFoundException(ExceptionCode.REPORT_NOT_FOUND);
        }
        //수면 종료시간 기준, 이전 24시간 활동데이터를 바탕으로 분석 요청
        const baseTime = sleepReport.sleepEndTime;
        const startTime = new Date(baseTime.getTime() - 24 * 60 * 60 * 1000);
        //현재시간에서 24시간 동안의 활동데이터를 가져옵니다.
        const activityDataList = await this.activityDataRepository.find({
            where: {
                userId: userId,
                activityEndTime: Between(startTime, baseTime),
            },
        });

        if (!activityDataList || activityDataList.length === 0) {
            throwNotFoundException(ExceptionCode.ACTIVITY_DATA_NOT_FOUND);
        }

        //fastAPI서버에 요청을 보내는 로직
        const activeTime :ActiveTime[] = activityDataList.map((activityData) => ({
            dataType : activityData.dataType,
            value : activityData.valueNumber,
            unit : activityData.unit
        }));
        const sleepTime: SleepTime[] = await this.settingSleepTimeData(sleepReport);

        this.settingSleepTimeData(sleepReport);
        const requestBody = {
            weekly_data: activeTime,
            night_data : sleepTime
        };
        const response = await axios.post('localhost:8082/coaching', {
            requestBody
        });
        console.log(response.data);
        return response;
    }

    private async settingSleepTimeData(sleepReport: SleepReport): Promise<any>{
        const lightSleep = {
            dataType : "LIGHT",
            value : this.intervalToMinutes(sleepReport.totalLightSleepTime),
            unit : "MINUTE"
        };

        const deepSleep = {
            dataType : "DEEP",
            value : this.intervalToMinutes(sleepReport.totalDeepSleepTime),
            unit : "MINUTE"
        };

        const remSleep = {
            dataType : "REM",
            value : this.intervalToMinutes(sleepReport.totalRemSleepTime),
            unit : "MINUTE"
        };

        const awake = {
            dataType : "AWAKE",
            value : this.intervalToMinutes(sleepReport.totalAwakeTime),
            unit : "MINUTE"
        };

        const sleepDiary = await this.sleepDiaryRepository.findOne({
            where: { sleepReportId: 1 },
        });
        const sleepScore = {
            dataType : "SLEEP_SCORE",
            value : sleepDiary?.sleepQuality,
            unit : "SCORE"
        };
        const sleepTime :SleepTime[] = [
            lightSleep,
            deepSleep,
            remSleep,
            awake,
            sleepScore
        ];
        return sleepTime;
    }

    private intervalToMinutes(interval :any) {
        const hours = interval.hours || 0;
        const minutes = interval.minutes || 0;
        const seconds = interval.seconds || 0;
        const totalMinutes = hours * 60 + minutes + Math.floor(seconds / 60);
        return totalMinutes;
    }
}