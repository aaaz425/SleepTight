class SleepEndRequest {
  final int reportId;
  final DateTime sleepEndTime;
  final List<Map<String, dynamic>> stages;

  SleepEndRequest({
    required this.reportId,
    required this.sleepEndTime,
    required this.stages,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'sleepEndTime': sleepEndTime.toUtc().toIso8601String(),
      'stages': stages,
    };
  }
}
