class UpdateUserMinSleepDurationRequest {
  final String minSleepDuration; // "8h 30m" 형식의 문자열

  UpdateUserMinSleepDurationRequest({required this.minSleepDuration});

  Map<String, dynamic> toJson() {
    return {'min_sleep_duration': minSleepDuration};
  }
}
