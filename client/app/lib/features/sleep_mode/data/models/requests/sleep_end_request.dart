class SleepEndRequest {
  final String sleepEndTime; // "00:00" 형식
  final int reportId;

  SleepEndRequest({required this.sleepEndTime, required this.reportId});

  Map<String, dynamic> toJson() {
    return {'sleep_end_time': sleepEndTime, 'reportId': reportId};
  }
}
