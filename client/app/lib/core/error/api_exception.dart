class ApiException implements Exception {
  final String? message; // 사용자에게 보여줄 메시지 또는 내부 로깅용 메시지
  final int? statusCode; // HTTP 상태 코드
  final String? errorCode; // API 자체 에러 코드 (예: data.status 값)
  final dynamic responseData; // 원본 응답 데이터

  ApiException({
    this.message,
    this.statusCode,
    this.errorCode,
    this.responseData,
  });

  @override
  String toString() {
    return 'ApiException: Status $statusCode, Code $errorCode, Message: $message';
  }
}
