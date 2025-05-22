class DurationInterval {
  final int? hours;
  final int? minutes;

  DurationInterval({this.hours, this.minutes});

  factory DurationInterval.fromJson(Map<String, dynamic> json) =>
      DurationInterval(
        hours: json['hours'] as int?,
        minutes: json['minutes'] as int?,
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (hours != null) data['hours'] = hours;
    if (minutes != null) data['minutes'] = minutes;
    return data;
  }
}

class SleepStage {
  final String stageType;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;

  SleepStage({
    required this.stageType,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });

  factory SleepStage.fromJson(Map<String, dynamic> json) => SleepStage(
    stageType: json['stageType'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    duration: json['duration'] as int,
  );

  Map<String, dynamic> toJson() => {
    'stageType': stageType,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'duration': duration,
  };
}

class SleepReportResponse {
  final int sleepReportId;
  final DateTime sleepStartTime;
  final DateTime sleepEndTime;
  final DurationInterval sleepLatency;
  final DurationInterval totalAwakeTime;
  final DurationInterval totalRemSleepTime;
  final DurationInterval totalLightSleepTime;
  final DurationInterval totalDeepSleepTime;
  final int awakenCount;
  final List<SleepStage> sleepStage;

  SleepReportResponse({
    required this.sleepReportId,
    required this.sleepStartTime,
    required this.sleepEndTime,
    required this.sleepLatency,
    required this.totalAwakeTime,
    required this.totalRemSleepTime,
    required this.totalLightSleepTime,
    required this.totalDeepSleepTime,
    required this.awakenCount,
    required this.sleepStage,
  });

  factory SleepReportResponse.fromJson(Map<String, dynamic> json) =>
      SleepReportResponse(
        sleepReportId: json['sleepReportId'] as int,
        sleepStartTime: DateTime.parse(json['sleep_start_time'] as String),
        sleepEndTime: DateTime.parse(json['sleep_end_time'] as String),
        sleepLatency: DurationInterval.fromJson(
          json['sleep_latency'] as Map<String, dynamic>,
        ),
        totalAwakeTime: DurationInterval.fromJson(
          json['total_awake_time'] as Map<String, dynamic>,
        ),
        totalRemSleepTime: DurationInterval.fromJson(
          json['total_rem_sleep_time'] as Map<String, dynamic>,
        ),
        totalLightSleepTime: DurationInterval.fromJson(
          json['total_light_sleep_time'] as Map<String, dynamic>,
        ),
        totalDeepSleepTime: DurationInterval.fromJson(
          json['total_deep_sleep_time'] as Map<String, dynamic>,
        ),
        awakenCount: json['awaken_count'] as int,
        sleepStage:
            (json['sleep_stage'] as List<dynamic>)
                .map((e) => SleepStage.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
    'sleepReportId': sleepReportId,
    'sleep_start_time': sleepStartTime.toIso8601String(),
    'sleep_end_time': sleepEndTime.toIso8601String(),
    'sleep_latency': sleepLatency.toJson(),
    'total_awake_time': totalAwakeTime.toJson(),
    'total_rem_sleep_time': totalRemSleepTime.toJson(),
    'total_light_sleep_time': totalLightSleepTime.toJson(),
    'total_deep_sleep_time': totalDeepSleepTime.toJson(),
    'awaken_count': awakenCount,
    'sleep_stage': sleepStage.map((e) => e.toJson()).toList(),
  };
}
