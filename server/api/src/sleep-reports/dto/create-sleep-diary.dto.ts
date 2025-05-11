import { WakeAwareness, WakeMethod } from '../entities/sleep-diary.entity';

export class CreateSleepDiaryDto {
  sleepReportId: number; // 수면 리포트 아이디를 client에서 받도록 추가
  sleepDate: string; // "YYYY-MM-DD"
  sleepTime: string; // "HH:MM:SS"
  wakeTime: string; // "HH:MM:SS"
  sleepLatency: string; // ISO8601 interval 문자열
  wakeCount: number;
  sleepQuality: number;
  moodScore: number;
  wakeAwareness: WakeAwareness;
  wakeMethod: WakeMethod;
  wakeMethodEtc?: string;
}
