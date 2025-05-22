class SleepStartResponse {
  final int reportId;

  SleepStartResponse({required this.reportId});

  factory SleepStartResponse.fromJson(Map<String, dynamic> json) {
    return SleepStartResponse(reportId: json['reportId'] as int);
  }
}
