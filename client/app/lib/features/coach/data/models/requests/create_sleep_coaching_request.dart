/// Request model for creating a sleep coaching entry.
class CreateSleepCoachingRequest {
  final int sleepReportId;

  CreateSleepCoachingRequest({required this.sleepReportId});

  Map<String, dynamic> toJson() => {'sleepReportId': sleepReportId};
}
