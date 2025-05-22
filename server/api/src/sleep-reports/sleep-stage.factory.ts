import { Injectable, Logger } from '@nestjs/common';
import { SleepStageLog } from './entities/sleep-stage-log.entity';
import { SleepStageDto } from './dto/end-sleep.request.dto';

@Injectable()
export class SleepStageFactory {
  private readonly logger = new Logger(SleepStageFactory.name);

  // KST 시간을 UTC로 변환하는 유틸리티 함수 (보다 안정적인 방식)
  private convertKSTtoUTC(kstDateStr: string): Date {
    // ISO 문자열에서 Date 객체 생성
    const date = new Date(kstDateStr);
    // KST는 UTC+9이므로, UTC로 변환하려면 9시간을 빼줌
    return new Date(date.getTime() - 9 * 60 * 60 * 1000);
  }

  create(dto: SleepStageDto, reportId: number): SleepStageLog {
    try {
      // 클라이언트에서 전달된 시간을 파싱하고 UTC로 변환
      const utcStart = this.convertKSTtoUTC(dto.startTime);
      const utcEnd = this.convertKSTtoUTC(dto.endTime);

      this.logger.debug(
        `수면 단계 변환 - 입력: ${dto.startTime} ~ ${dto.endTime}, 변환 결과(UTC): ${utcStart.toISOString()} ~ ${utcEnd.toISOString()}`,
      );

      // 변환 결과 검증 - 종료 시간이 시작 시간보다 빠르면 오류 로그
      if (utcEnd.getTime() <= utcStart.getTime()) {
        this.logger.warn(
          `수면 단계 시간 이상: 종료 시간이 시작 시간보다 이전입니다`,
          {
            start: dto.startTime,
            end: dto.endTime,
            utcStart: utcStart.toISOString(),
            utcEnd: utcEnd.toISOString(),
          },
        );
      }

      const stage = new SleepStageLog();
      stage.sleepReportId = reportId;
      stage.stageType = dto.stageType;
      stage.stageStartTime = utcStart;
      stage.stageEndTime = utcEnd;
      stage.durationMinutes = Math.max(
        0,
        Math.floor((utcEnd.getTime() - utcStart.getTime()) / 60000),
      );

      return stage;
    } catch (error) {
      this.logger.error(`수면 단계 변환 중 오류 발생: ${error.message}`, {
        startTime: dto.startTime,
        endTime: dto.endTime,
        reportId,
      });
      // 오류가 발생해도 기본 처리를 시도
      const fallbackStart = new Date(dto.startTime);
      const fallbackEnd = new Date(dto.endTime);

      const stage = new SleepStageLog();
      stage.sleepReportId = reportId;
      stage.stageType = dto.stageType;
      stage.stageStartTime = fallbackStart;
      stage.stageEndTime = fallbackEnd;
      stage.durationMinutes = Math.max(
        0,
        Math.floor((fallbackEnd.getTime() - fallbackStart.getTime()) / 60000),
      );

      return stage;
    }
  }
}
