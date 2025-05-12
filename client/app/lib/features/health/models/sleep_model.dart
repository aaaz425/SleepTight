// lib/features/health/models/sleep_model.dart
import 'package:health/health.dart'; // HealthDataType 사용을 위해 (나중에 변환 로직에서)

// 수면 단계를 나타내는 Enum
enum SleepStage {
  AWAKE, // SLEEP_AWAKE
  LIGHT, // SLEEP_LIGHT
  DEEP, // SLEEP_DEEP
  REM, // SLEEP_REM
  ASLEEP, // SLEEP_ASLEEP (단계 구분 불가)
  UNKNOWN, // HealthDataType에 매칭되지 않는 경우
}

// SleepStage enum을 문자열로 변환 (서버 전송용)
String sleepStageToString(SleepStage stage) {
  switch (stage) {
    case SleepStage.AWAKE:
      return HealthDataType.SLEEP_AWAKE.name; // "SLEEP_AWAKE"
    case SleepStage.LIGHT:
      return HealthDataType.SLEEP_LIGHT.name; // "SLEEP_LIGHT"
    case SleepStage.DEEP:
      return HealthDataType.SLEEP_DEEP.name; // "SLEEP_DEEP"
    case SleepStage.REM:
      return HealthDataType.SLEEP_REM.name; // "SLEEP_REM"
    case SleepStage.ASLEEP:
      return HealthDataType.SLEEP_ASLEEP.name; // "SLEEP_ASLEEP"
    default:
      return "UNKNOWN";
  }
}

// HealthDataType.name 문자열을 SleepStage enum으로 변환 (데이터 처리용)
SleepStage healthDataTypeToSleepStage(String typeName) {
  if (typeName == HealthDataType.SLEEP_AWAKE.name) {
    return SleepStage.AWAKE;
  } else if (typeName == HealthDataType.SLEEP_LIGHT.name) {
    return SleepStage.LIGHT;
  } else if (typeName == HealthDataType.SLEEP_DEEP.name) {
    return SleepStage.DEEP;
  } else if (typeName == HealthDataType.SLEEP_REM.name) {
    return SleepStage.REM;
  } else if (typeName == HealthDataType.SLEEP_ASLEEP.name) {
    return SleepStage.ASLEEP;
  }
  return SleepStage.UNKNOWN; // 기본값 또는 오류 처리
}

// 개별 수면 단계를 나타내는 모델 (시계열 데이터용)
class SleepSegment {
  final DateTime startTime;
  final DateTime endTime;
  final SleepStage stage; // Enum 타입으로 변경
  final double durationInMinutes;

  SleepSegment({
    required this.startTime,
    required this.endTime,
    required this.stage,
    required this.durationInMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'stage': sleepStageToString(stage), // Enum을 문자열로 변환하여 전송
      'durationInMinutes': durationInMinutes,
    };
  }
}

class SleepSessionData {
  final DateTime sessionStartTime;
  final DateTime sessionEndTime;
  final DateTime date;

  final double totalSleepMinutes;
  final double awakeMinutesInSleep;
  final double deepSleepMinutes;
  final double lightSleepMinutes;
  final double remSleepMinutes;

  final List<SleepSegment> segments;

  SleepSessionData({
    required this.sessionStartTime,
    required this.sessionEndTime,
    required this.date,
    required this.totalSleepMinutes,
    required this.awakeMinutesInSleep,
    required this.deepSleepMinutes,
    required this.lightSleepMinutes,
    required this.remSleepMinutes,
    required this.segments,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionStartTime': sessionStartTime.toIso8601String(),
      'sessionEndTime': sessionEndTime.toIso8601String(),
      'date': date.toIso8601String().substring(0, 10),
      'summary': {
        'totalSleepMinutes': totalSleepMinutes,
        'awakeMinutesInSleep': awakeMinutesInSleep,
        'deepSleepMinutes': deepSleepMinutes,
        'lightSleepMinutes': lightSleepMinutes,
        'remSleepMinutes': remSleepMinutes,
      },
      'segments': segments.map((segment) => segment.toJson()).toList(),
    };
  }
}
