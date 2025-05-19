import { ApiProperty } from '@nestjs/swagger';

export class SleepReportCalendarResponseDto {
  @ApiProperty({
    type: [Number],
    example: [1, 3, 5, 9, 10],
    description: '해당 월에 수면 리포트가 존재하는 날짜 배열',
  })
  date: number[];
}
