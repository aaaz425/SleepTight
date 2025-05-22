class SleepReportSoundResponse {
  final int reportId;
  final DateTime date;
  final List<SoundItem> sounds;

  SleepReportSoundResponse({
    required this.reportId,
    required this.date,
    required this.sounds,
  });

  factory SleepReportSoundResponse.fromJson(Map<String, dynamic> json) =>
      SleepReportSoundResponse(
        reportId: json['reportId'] as int,
        date: DateTime.parse(json['date'] as String),
        sounds:
            (json['sounds'] as List<dynamic>)
                .map((e) => SoundItem.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  Map<String, dynamic> toJson() => {
    'reportId': reportId,
    // DATE만 필요한 경우 .split('T').first 로 자를 수 있습니다.
    'date': date.toIso8601String().split('T').first,
    'sounds': sounds.map((e) => e.toJson()).toList(),
  };
}

class SoundItem {
  final int soundId;
  final List<SoundEvent> events;
  final String soundStartTime;
  final String soundEndTime;
  final String clipUrl;

  SoundItem({
    required this.soundId,
    required this.events,
    required this.soundStartTime,
    required this.soundEndTime,
    required this.clipUrl,
  });

  factory SoundItem.fromJson(Map<String, dynamic> json) => SoundItem(
    soundId: json['soundId'] as int,
    events:
        (json['events'] as List<dynamic>)
            .map((e) => SoundEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
    soundStartTime: json['soundStartTime'] as String,
    soundEndTime: json['soundEndTime'] as String,
    clipUrl: json['clipUrl'] as String,
  );

  Map<String, dynamic> toJson() => {
    'soundId': soundId,
    'events': events.map((e) => e.toJson()).toList(),
    'soundStartTime': soundStartTime,
    'soundEndTime': soundEndTime,
    'clipUrl': clipUrl,
  };
}

class SoundEvent {
  final String eventId;
  final String anomaly;
  final int eventStartSec;
  final int eventEndSec;

  SoundEvent({
    required this.eventId,
    required this.anomaly,
    required this.eventStartSec,
    required this.eventEndSec,
  });

  factory SoundEvent.fromJson(Map<String, dynamic> json) => SoundEvent(
    eventId: json['eventId'] as String,
    anomaly: json['anomaly'] as String,
    eventStartSec: json['eventStartSec'] as int,
    eventEndSec: json['eventEndSec'] as int,
  );

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'anomaly': anomaly,
    'eventStartSec': eventStartSec,
    'eventEndSec': eventEndSec,
  };
}

// anomaly data
