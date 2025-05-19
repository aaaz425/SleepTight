import { ApiProperty } from "@nestjs/swagger";
import { Expose } from "class-transformer";

export class RequestUpdateNameDto {
    @ApiProperty()
    @Expose({name : 'firstName'})
    firstName: string
    @ApiProperty()
    @Expose({name : 'lastName'})
    lastName: string
}