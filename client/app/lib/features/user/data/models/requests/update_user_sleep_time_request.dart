class UpdateUserSleepTimeRequest {
  final String sleepTime; // "HH:MM" 형식의 문자열 (예: "23:30")

  UpdateUserSleepTimeRequest({required this.sleepTime});

  Map<String, dynamic> toJson() {
    return {'sleep_time': sleepTime};
  }
}
