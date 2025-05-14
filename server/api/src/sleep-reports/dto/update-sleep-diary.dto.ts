import { WakeAwareness, WakeMethod } from '../entities/sleep-diary.entity';

export class UpdateSleepDiaryDto {
  sleepReportId: number;
  sleepTime?: string;
  wakeTime?: string;
  sleepLatency?: string;
  wakeCount?: number;
  sleepQuality?: number;
  moodScore?: number;
  wakeAwareness?: WakeAwareness;
  wakeMethod?: WakeMethod;
  wakeMethodEtc?: string;
}
