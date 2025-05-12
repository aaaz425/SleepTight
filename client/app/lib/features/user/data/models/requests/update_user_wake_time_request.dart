class UpdateUserWakeTimeRequest {
  final String wakeTime; // "HH:MM" 형식의 문자열 (예: "07:30")

  UpdateUserWakeTimeRequest({required this.wakeTime});

  Map<String, dynamic> toJson() {
    return {'wake_time': wakeTime};
  }
}
