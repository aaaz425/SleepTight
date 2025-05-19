import { ApiProperty } from "@nestjs/swagger";
import { Expose } from "class-transformer";

export class RequestUpdateWeightDto {
    @ApiProperty({description : '몸무게'})
    weight: number;
    @ApiProperty({description : '단위'})
    @Expose({ name:"weight_unit" })
    weightUnit: string;
}