class UserSleepGoalResponse {
  final String minSleepDuration; // 예: "8h 30m"
  final String sleepTime; // 예: "11:00"
  final String wakeTime; // 예: "06:00"

  UserSleepGoalResponse({
    required this.minSleepDuration,
    required this.sleepTime,
    required this.wakeTime,
  });

  factory UserSleepGoalResponse.fromJson(Map<String, dynamic> json) {
    return UserSleepGoalResponse(
      minSleepDuration: json['min_sleep_duration'],
      sleepTime: json['sleep_time'],
      wakeTime: json['wake_time'],
    );
  }
}
