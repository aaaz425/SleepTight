import { WakeAwareness, WakeMethod } from '../entities/sleep-diary.entity';

export class CreateSleepDiaryDto {
  sleepDate: string;       // "YYYY-MM-DD"
  sleepTime: string;       // "HH:MM:SS"
  wakeTime: string;        // "HH:MM:SS"
  sleepLatency: string;
  wakeCount: number;
  sleepQuality: number;
  moodScore: number;
  wakeAwareness: WakeAwareness;
  wakeMethod: WakeMethod;
  wakeMethodEtc?: string;
}