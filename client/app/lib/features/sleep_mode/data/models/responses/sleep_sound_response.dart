class SleepSoundResponse {
  final String segmentId; // UUID

  SleepSoundResponse({required this.segmentId});

  factory SleepSoundResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SleepSoundResponse(segmentId: data['segmentId']);
  }
}
