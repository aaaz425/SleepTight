class SleepReport {
  final int sleepReportId;
  final DateTime sleepStartTime;
  final DateTime sleepEndTime;
  final Duration sleepLatency;
  final Duration totalAwakeTime;
  final Duration totalRemSleepTime;
  final Duration totalLightSleepTime;
  final Duration totalDeepSleepTime;
  final int awakenCount;
  final List<SleepStage> sleepStages;

  SleepReport({
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

  factory SleepReport.fromJson(Map<String, dynamic> json) {
    return SleepReport(
      sleepReportId: json['sleepReportId'],
      sleepStartTime: DateTime.parse(json['sleep_start_time']),
      sleepEndTime: DateTime.parse(json['sleep_end_time']),
      sleepLatency: Duration(minutes: json['sleep_latency']['minutes']),
      totalAwakeTime: Duration(
        hours: json['total_awake_time']['hours'] ?? 0,
        minutes: json['total_awake_time']['minutes'] ?? 0,
      ),
      totalRemSleepTime: Duration(
        hours: json['total_rem_sleep_time']['hours'] ?? 0,
        minutes: json['total_rem_sleep_time']['minutes'] ?? 0,
      ),
      totalLightSleepTime: Duration(
        hours: json['total_light_sleep_time']['hours'] ?? 0,
        minutes: json['total_light_sleep_time']['minutes'] ?? 0,
      ),
      totalDeepSleepTime: Duration(
        hours: json['total_deep_sleep_time']['hours'] ?? 0,
        minutes: json['total_deep_sleep_time']['minutes'] ?? 0,
      ),
      awakenCount: json['awaken_count'],
      sleepStages:
          (json['sleep_stage'] as List)
              .map((e) => SleepStage.fromJson(e))
              .toList(),
    );
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

  factory SleepStage.fromJson(Map<String, dynamic> json) {
    return SleepStage(
      stageType: json['stageType'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      duration: int.parse(json['duration'].toString()),
    );
  }
}
