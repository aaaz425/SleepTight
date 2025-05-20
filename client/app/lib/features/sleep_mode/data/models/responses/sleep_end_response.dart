class SleepEndResponse {
  final bool isValidReport;

  SleepEndResponse({required this.isValidReport});

  factory SleepEndResponse.fromJson(Map<String, dynamic> json) {
    final isValid = json['isValidReport'] == true;
    return SleepEndResponse(isValidReport: isValid);
  }
}
