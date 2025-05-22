class SleepSoundResponse {
  final String segmentId; // UUID

  SleepSoundResponse({required this.segmentId});

  factory SleepSoundResponse.fromJson(Map<String, dynamic> json) {
    return SleepSoundResponse(segmentId: json['segmentId']);
  }
}
