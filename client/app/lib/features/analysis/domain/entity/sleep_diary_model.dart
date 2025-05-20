import 'package:sleep_tight/features/analysis/data/models/enums/wake_awareness.dart';
import 'package:sleep_tight/features/analysis/data/models/enums/wake_method.dart';

class SleepDiaryModel {
  final int id;
  final int sleepReportId;
  final String sleepDate; // YYYY-MM-DD
  final String sleepTime; // HH:MM:SS
  final String wakeTime; // HH:MM:SS
  final String sleepLatency; // HH:MM:SS 포맷
  final int? wakeCount;
  final int? sleepQuality;
  final int? moodScore;
  final WakeAwareness? wakeAwareness;
  final WakeMethod? wakeMethod;
  final String? wakeMethodEtc;

  SleepDiaryModel({
    required this.id,
    required this.sleepReportId,
    required this.sleepDate,
    required this.sleepTime,
    required this.wakeTime,
    required this.sleepLatency,
    this.wakeCount,
    this.sleepQuality,
    this.moodScore,
    this.wakeAwareness,
    this.wakeMethod,
    this.wakeMethodEtc,
  });

  @override
  String toString() {
    return 'SleepDiaryModel(id: $id, sleepReportId: $sleepReportId, sleepDate: $sleepDate, sleepTime: $sleepTime, wakeTime: $wakeTime, sleepLatency: $sleepLatency, wakeCount: $wakeCount, sleepQuality: $sleepQuality, moodScore: $moodScore, wakeAwareness: $wakeAwareness, wakeMethod: $wakeMethod, wakeMethodEtc: $wakeMethodEtc)';
  }
}
