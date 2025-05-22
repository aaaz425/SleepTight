class SleepReportModel {
  final int sleepReportId;
  final DateTime sleepStartTime;
  final DateTime sleepEndTime;
  final Duration? sleepLatency;
  final Duration? totalAwakeTime;
  final Duration? totalRemSleepTime;
  final Duration? totalLightSleepTime;
  final Duration? totalDeepSleepTime;
  final int? awakenCount;
  final List<SleepStageModel> sleepStages;

  SleepReportModel({
    required this.sleepReportId,
    required this.sleepStartTime,
    required this.sleepEndTime,
    required this.sleepLatency,
    required this.totalAwakeTime,
    required this.totalRemSleepTime,
    required this.totalLightSleepTime,
    required this.totalDeepSleepTime,
    required this.awakenCount,
    required this.sleepStages,
  });

  factory SleepReportModel.fromJson(Map<String, dynamic> json) {
    return SleepReportModel(
      sleepLatency: parseDuration(json['sleep_latency']),
      totalAwakeTime: parseDuration(json['total_awake_time']),
      totalLightSleepTime: parseDuration(json['total_light_sleep_time']),
      totalDeepSleepTime: parseDuration(json['total_deep_sleep_time']),
      totalRemSleepTime: parseDuration(json['total_rem_sleep_time']),
      awakenCount: json['awaken_count'] ?? 0,
      sleepStages:
          (json['sleep_stage'] as List<dynamic>?)
              ?.map((e) => SleepStageModel.fromJson(e))
              .toList() ??
          [],
      sleepStartTime: DateTime.parse(json['sleep_start_time']),
      sleepEndTime: DateTime.parse(json['sleep_end_time']),
      sleepReportId: json['sleepReportId'],
    );
  }
}

class SleepStageModel {
  final String stageType;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;

  SleepStageModel({
    required this.stageType,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });

  factory SleepStageModel.fromJson(Map<String, dynamic> json) {
    return SleepStageModel(
      stageType: json['stageType'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: int.parse(json['duration'].toString()),
    );
  }
}

Duration parseDuration(dynamic json) {
  if (json == null || json is! Map<String, dynamic>) {
    return Duration.zero;
  }

  final hours = json['hours'];
  final minutes = json['minutes'];

  return Duration(
    hours: (hours is int) ? hours : 0,
    minutes: (minutes is int) ? minutes : 0,
  );
}
