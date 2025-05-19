import { ApiProperty } from "@nestjs/swagger";
import { Expose } from "class-transformer";

export class RequestUpdateHeightDto {
    @ApiProperty({description : '키'})
    height: number;
    @ApiProperty({description : '단위'})
    @Expose({ name:"length_unit" })
    lengthUnit: string;
}