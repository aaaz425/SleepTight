import '../enums/wake_awareness.dart';
import '../enums/wake_method.dart';

/// 수면 일지 단건 응답 모델
class SleepDiaryResponse {
  final int id;
  final int sleepReportId;
  final String sleepDate; // “YYYY-MM-DD”
  final String sleepTime; // “HH:MM:SS”
  final String wakeTime; // “HH:MM:SS”
  final int sleepLatency; // 분 단위 정수
  final int? wakeCount;
  final int? sleepQuality;
  final int? moodScore;
  final WakeAwareness? wakeAwareness;
  final WakeMethod? wakeMethod;
  final String? wakeMethodEtc;

  SleepDiaryResponse({
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

  // JSON에서 Date 또는 Time 객체가 String 또는 Map 형태로 올 때 처리
  static String _parseDate(dynamic v) {
    if (v is String) return v;
    if (v is Map<String, dynamic>) {
      final y = v['year']?.toString().padLeft(4, '0');
      final m = v['month']?.toString().padLeft(2, '0');
      final d = v['day']?.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }
    return v?.toString() ?? '';
  }

  static String _parseTime(dynamic v) {
    if (v is String) return v;
    if (v is Map<String, dynamic>) {
      final h = v['hour']?.toString().padLeft(2, '0');
      final m = v['minute']?.toString().padLeft(2, '0');
      final s = v['second']?.toString().padLeft(2, '0');
      return '$h:$m:$s';
    }
    return v?.toString() ?? '';
  }

  // JSON에서 sleepLatency 객체 또는 문자열을 분 단위 정수로 변환
  static int _parseLatency(dynamic v) {
    if (v is int) return v;
    if (v is String) {
      final parts = v.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        return h * 60 + m;
      }
      return int.tryParse(v) ?? 0;
    }
    if (v is Map<String, dynamic>) {
      final h = v['hours'] as int? ?? 0;
      final m = v['minutes'] as int? ?? 0;
      return h * 60 + m;
    }
    return 0;
  }

  factory SleepDiaryResponse.fromJson(Map<String, dynamic> json) {
    return SleepDiaryResponse(
      id: json['id'] as int,
      sleepReportId: json['sleepReportId'] as int,
      sleepDate: _parseDate(json['sleepDate']),
      sleepTime: _parseTime(json['sleepTime']),
      wakeTime: _parseTime(json['wakeTime']),
      sleepLatency: _parseLatency(json['sleepLatency']),
      wakeCount: json['wakeCount'] as int?,
      sleepQuality: json['sleepQuality'] as int?,
      moodScore: json['moodScore'] as int?,
      wakeAwareness:
          json['wakeAwareness'] == null
              ? null
              : WakeAwarenessExtension.fromJson(
                json['wakeAwareness'] as String,
              ),
      wakeMethod:
          json['wakeMethod'] == null
              ? null
              : WakeMethodExtension.fromJson(json['wakeMethod'] as String),
      wakeMethodEtc: json['wakeMethodEtc'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'sleepReportId': sleepReportId,
      'sleepDate': sleepDate,
      'sleepTime': sleepTime,
      'wakeTime': wakeTime,
      'sleepLatency': sleepLatency,
    };
    if (wakeCount != null) data['wakeCount'] = wakeCount;
    if (sleepQuality != null) data['sleepQuality'] = sleepQuality;
    if (moodScore != null) data['moodScore'] = moodScore;
    if (wakeAwareness != null) data['wakeAwareness'] = wakeAwareness!.toJson();
    if (wakeMethod != null) data['wakeMethod'] = wakeMethod!.toJson();
    if (wakeMethodEtc != null) data['wakeMethodEtc'] = wakeMethodEtc;
    return data;
  }
}
