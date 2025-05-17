class SleepStartRequest {
  final String sleepStartTime;

  SleepStartRequest({required this.sleepStartTime});

  Map<String, dynamic> toJson() {
    return {'sleep_start_time': sleepStartTime};
  }
}
