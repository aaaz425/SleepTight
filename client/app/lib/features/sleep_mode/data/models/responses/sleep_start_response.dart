class SleepStartResponse {
  final int reportId;

  SleepStartResponse({required this.reportId});

  factory SleepStartResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SleepStartResponse(reportId: data['reportId']);
  }
}
