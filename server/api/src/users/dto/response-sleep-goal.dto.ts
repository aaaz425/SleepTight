import { Expose } from "class-transformer"
import { User } from "../entities/user.entity"

export class ResponseSleepGoalDto {
    @Expose({name : 'min_sleep_duration'})
    minSleepDuration: string
    @Expose({name : 'sleep_time'})
    sleepTime: string
    @Expose({name : 'wake_time'})
    wakeTime: string

    static fromEntity(user: User): ResponseSleepGoalDto{
        const dto: ResponseSleepGoalDto = new ResponseSleepGoalDto();
        dto.sleepTime = user.sleep_time;
        dto.wakeTime = user.wake_time;
        // const interval = parse(user.min_sleep_duration);
        // const hours = interval.hours;
        // const minutes = interval.minutes;
        // const formatted = `${hours}h ${minutes}m`;
        // dto.minSleepDuration = formatted;
        return dto;
    }
}