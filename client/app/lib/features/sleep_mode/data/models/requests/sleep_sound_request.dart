class SleepSoundRequest {
  final int reportId;
  final String segmentId; // UUID
  final DateTime timestamp; // ISO8601
  final double duration; // 초 단위

  SleepSoundRequest({
    required this.reportId,
    required this.segmentId,
    required this.timestamp,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'segmentId': segmentId,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
    };
  }
}
