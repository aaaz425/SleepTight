import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Between, Repository } from "typeorm";
import { ActivityData } from "./entities/activity-data.entity";
import { throwNotFoundException } from "src/common/exceptions/exception.helper";
import { ExceptionCode } from "src/common/exceptions/exception-code.enum";
import { SleepReport } from "src/sleep-reports/entities/sleep-report.entity";
import { ActiveTime } from "./interfaces/active-time.interface";

@Injectable()
export class SleepCoachingService {
    constructor(
        @InjectRepository(ActivityData)
        private readonly activityDataRepository: Repository<ActivityData>,
        @InjectRepository(SleepReport)
        private readonly sleepReportRepository: Repository<SleepReport>,
    ) {}

    async getSleepCoaching(userId: number, sleepReportId :number): Promise<any> {
        // const sleepReport: SleepReport | null = await this.sleepReportRepository.findOneBy({id : sleepReportId});
        // if(!sleepReport) {
        //     throwNotFoundException(ExceptionCode.REPORT_NOT_FOUND);
        // }

        // //수면 종료시간 기준, 이전 24시간 활동데이터를 바탕으로 분석 요청
        // const baseTime = sleepReport.sleepEndTime;
        // const startTime = new Date(baseTime.getTime() - 24 * 60 * 60 * 1000);
        
        // //현재시간에서 24시간 동안의 활동데이터를 가져옵니다.
        // const activityDataList = await this.activityDataRepository.find({
        //     where: {
        //         userId: userId,
        //         createdAt: Between(startTime, baseTime),
        //     },
        // });

        // if (!activityDataList || activityDataList.length === 0) {
        //     throwNotFoundException(ExceptionCode.ACTIVITY_DATA_NOT_FOUND);
        // }

        //테스트용
        const baseTime = new Date("2025-05-15T07:49:18Z")
        const startTime = new Date(baseTime.getTime() - 24 * 60 * 60 * 1000);
        const activityDataList = await this.activityDataRepository.find({
            where: {
                userId: userId,
                createdAt: Between(startTime, baseTime),
            },
        });

        //TODO: fastAPI서버에 요청을 보내는 로직을 추가합니다.
        const activeTime :ActiveTime[] = activityDataList.map((activityData) => ({
            dataType : activityData.dataType,
            value : activityData.valueNumber,
            unit : activityData.unit
        }));
        
        const requestBody = {
            weekly_data: activeTime,
        };
        console.log(requestBody)
    }
}