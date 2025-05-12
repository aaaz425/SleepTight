class SleepStartRequest {
  final String sleepStartTime; // "00:00" 형식

  SleepStartRequest({required this.sleepStartTime});

  Map<String, dynamic> toJson() {
    return {'sleep_start_time': sleepStartTime};
  }
}
