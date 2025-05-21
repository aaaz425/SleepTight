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

  // 이상현상 유형별 개수를 반환 (예: "코골이(2), 기침(1)")
  String getAnomalyText() {
    if (events.isEmpty) {
      return "이상현상 없음";
    }

    final Map<String, int> anomalyCounts = {};

    for (final event in events) {
      final anomalyName = translateAnomaly(event.anomaly);
      if (anomalyCounts.containsKey(anomalyName)) {
        anomalyCounts[anomalyName] = anomalyCounts[anomalyName]! + 1;
      } else {
        anomalyCounts[anomalyName] = 1;
      }
    }

    final anomalyTexts =
        anomalyCounts.entries.map((entry) {
          final name = entry.key;
          final count = entry.value;

          if (count > 1) {
            return "$name($count)";
          } else {
            return name;
          }
        }).toList();

    return anomalyTexts.join(", ");
  }

  // 전체 클립 길이 (초)
  int getClipDurationInSeconds() {
    if (events.isEmpty) return 10; // 기본값 10초

    int maxEndSec = 0;
    for (final event in events) {
      if (event.eventEndSec > maxEndSec) {
        maxEndSec = event.eventEndSec;
      }
    }

    return maxEndSec > 0 ? maxEndSec + 2 : 10; // 마지막 이벤트 후 2초 추가
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

// 이상현상 코드를 한글로 변환
String translateAnomaly(String anomalyCode) {
  switch (anomalyCode.toUpperCase()) {
    case 'SNORE':
      return '코골이';
    case 'COUGH':
      return '기침';
    case 'SOMNILOQUY':
      return '잠꼬대';
    default:
      return anomalyCode;
  }
}
