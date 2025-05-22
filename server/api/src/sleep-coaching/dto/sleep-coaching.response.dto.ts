import { SleepCoaching } from "../entities/sleep-coaching.entity";

export class SleepCoachingResponseDto {
    activity: string
    type: string
    value: number
    description: string

    static fromEntity(sleepCoaching: SleepCoaching) {
        const dto: SleepCoachingResponseDto = new SleepCoachingResponseDto();
        dto.activity = sleepCoaching.activity
        dto.type = sleepCoaching.type
        dto.value = sleepCoaching.value
        dto.description = sleepCoaching.description
        return dto;
    }
}