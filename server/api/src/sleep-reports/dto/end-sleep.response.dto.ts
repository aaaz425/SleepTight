import { ApiProperty } from '@nestjs/swagger';

export class EndSleepResponseDto {
  @ApiProperty({ example: true, description: '유효 수면 여부' })
  isValidReport: boolean;
}
