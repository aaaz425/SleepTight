class SleepSoundModel {
  final int soundId;
  final String soundStartTime;
  final String soundEndTime;
  final String clipUrl;
  final List<SleepEventModel> events;

  SleepSoundModel({
    required this.soundId,
    required this.soundStartTime,
    required this.soundEndTime,
    required this.clipUrl,
    required this.events,
  });

  factory SleepSoundModel.fromJson(Map<String, dynamic> json) {
    return SleepSoundModel(
      soundId: json['soundId'],
      soundStartTime: json['soundStartTime'],
      soundEndTime: json['soundEndTime'],
      clipUrl: json['clipUrl'],
      events:
          (json['events'] as List<dynamic>?)
              ?.map((e) => SleepEventModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SleepEventModel {
  final int eventId;
  final String anomaly;
  final int eventStartSec;
  final int eventEndSec;
  final double? confidence;

  SleepEventModel({
    required this.eventId,
    required this.anomaly,
    required this.eventStartSec,
    required this.eventEndSec,
    this.confidence,
  });

  factory SleepEventModel.fromJson(Map<String, dynamic> json) {
    return SleepEventModel(
      eventId: json['eventId'],
      anomaly: json['anomaly'],
      eventStartSec: json['eventStartSec'],
      eventEndSec: json['eventEndSec'],
      confidence:
          json['confidence'] != null
              ? double.tryParse(json['confidence'].toString())
              : null,
    );
  }
}
