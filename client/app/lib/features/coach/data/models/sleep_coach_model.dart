import 'package:sleep_tight/features/coach/data/models/sleep_coach_type_enum.dart';

class SleepCoachModel {
  final ActivityDataType activity;
  final String type;
  final double value;
  final String description;

  SleepCoachModel({
    required this.activity,
    required this.type,
    required this.value,
    required this.description,
  });

  factory SleepCoachModel.fromJson(Map<String, dynamic> json) {
    return SleepCoachModel(
      activity: (json['activity'] as String).toActivityDataType(),
      type: json['type'] as String,
      value: double.tryParse(json['value'].toString()) ?? 0.0,
      description: json['description'] as String,
    );
  }
}
