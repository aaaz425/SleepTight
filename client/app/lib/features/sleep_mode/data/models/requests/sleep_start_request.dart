class SleepStartRequest {
  final DateTime sleepStartTime;

  SleepStartRequest({required this.sleepStartTime});

  Map<String, dynamic> toJson() => {
    'sleep_start_time': sleepStartTime.toUtc().toIso8601String(),
  };
}
