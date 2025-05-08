import { PartialType } from '@nestjs/swagger';
import { CreateSleepDiaryDto } from './create-sleep-diary.dto';

export class UpdateSleepDiaryDto extends PartialType(CreateSleepDiaryDto) {
  // Body로 전달된 필드만 덮어쓰기
}
