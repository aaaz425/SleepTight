import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { ActivityData } from "./entities/activity-data.entity";
import { throwNotFoundException } from "src/common/exceptions/exception.helper";
import { ExceptionCode } from "src/common/exceptions/exception-code.enum";

@Injectable()
export class SleepCoachingService {
    constructor(
        private readonly activityDataRepository: Repository<ActivityData>,
    ) {}

    async getSleepCoaching(userId: number, date :Date): Promise<any> {
        // userId와 date를 사용하여 ActivityData를 조회합니다.
        const activityData = await this.activityDataRepository.findOne({
            where: {
                userId: userId,
                createdAt: date,
            },
        });

        if (!activityData) {
            throwNotFoundException(ExceptionCode.ACTIVITY_DATA_NOT_FOUND);
        }
        //TODO: fastAPI서버에 요청을 보내는 로직을 추가합니다.
        
    }
}