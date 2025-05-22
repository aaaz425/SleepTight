import { ApiProperty } from "@nestjs/swagger";
import { Expose } from "class-transformer";

export class RequestUpdateBirthDateDto {
    @ApiProperty()
    @Expose({name : 'birthDate'})
    birthDate: Date

}