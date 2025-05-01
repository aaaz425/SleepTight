
export class RequestLoginDto {
    accessToken: string;
    refreshToken: string;
    //유저 정보
    id: number;
    provider: string;
    lastName: string;
    firstName: string;
    email: string;
    wakeTime: string;
    sleepTime: string;
    minSleepDuration: string;
    weight: number
    height: number
    gender: string
}