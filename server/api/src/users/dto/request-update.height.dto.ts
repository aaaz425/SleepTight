import { Expose } from "class-transformer";

export class RequestUpdateHeightDto {
    height: number;
    @Expose({ name:"length_unit" })
    lengthUnit: string;
}