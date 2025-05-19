import { ApiProperty } from "@nestjs/swagger";
import { Expose } from "class-transformer";

export class createSleepCoachingDto {
    @ApiProperty({name : 'sleepReportId'})
    @Expose({name : 'sleepReportId'})
    sleepReportId: number
}