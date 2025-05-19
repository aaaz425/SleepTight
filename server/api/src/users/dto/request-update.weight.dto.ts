import { Expose } from "class-transformer";

export class RequestUpdateWeightDto {
    weight: number;
    @Expose({ name:"weight_unit" })
    weightUnit: string;
}