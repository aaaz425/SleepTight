class SleepEndRequest {
  final int reportId;
  final String sleepEndTime;
  final List<Map<String, dynamic>> stages;

  SleepEndRequest({
    required this.reportId,
    required this.sleepEndTime,
    required this.stages,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'sleepEndTime': sleepEndTime,
      'stages': stages,
    };
  }
}
