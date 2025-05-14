import { ApiProperty } from '@nestjs/swagger';

export class StartSleepResponseDto {
  @ApiProperty({ example: 25, description: '생성된 수면 리포트 ID' })
  reportId: number;
}
