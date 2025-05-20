import 'package:sleep_tight/features/analysis/data/models/enums/wake_awareness.dart';
import 'package:sleep_tight/features/analysis/data/models/enums/wake_method.dart';

/// 수면 일지 수정 요청 모델
class UpdateSleepDiaryRequest {
  final int sleepReportId;
  final String? sleepDate; // YYYY-MM-DD
  final String? sleepTime; // HH:MM:SS
  final String? wakeTime; // HH:MM:SS
  final String? sleepLatency; // HH:MM:SS
  final int? wakeCount;
  final int? sleepQuality;
  final int? moodScore;
  final WakeAwareness? wakeAwareness;
  final WakeMethod? wakeMethod;
  final String? wakeMethodEtc;

  UpdateSleepDiaryRequest({
    required this.sleepReportId,
    this.sleepDate,
    this.sleepTime,
    this.wakeTime,
    this.sleepLatency,
    this.wakeCount,
    this.sleepQuality,
    this.moodScore,
    this.wakeAwareness,
    this.wakeMethod,
    this.wakeMethodEtc,
  });

  Map<String, dynamic> toJson() => {
    'sleepReportId': sleepReportId,
    if (sleepDate != null) 'sleepDate': sleepDate,
    if (sleepTime != null) 'sleepTime': sleepTime,
    if (wakeTime != null) 'wakeTime': wakeTime,
    if (sleepLatency != null) 'sleepLatency': sleepLatency,
    if (wakeCount != null) 'wakeCount': wakeCount,
    if (sleepQuality != null) 'sleepQuality': sleepQuality,
    if (moodScore != null) 'moodScore': moodScore,
    if (wakeAwareness != null) 'wakeAwareness': wakeAwareness!.toJson(),
    if (wakeMethod != null) 'wakeMethod': wakeMethod!.toJson(),
    if (wakeMethodEtc != null) 'wakeMethodEtc': wakeMethodEtc,
  };
}
