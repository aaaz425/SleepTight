enum ErrorCode {
  USER_NOT_FOUND(
    httpStatus: 400,
    code: 'USER_NOT_FOUND',
    message: '유저를 찾을 수 없습니다.',
  ),
  MUSIC_NOT_FOUND(
    httpStatus: 400,
    code: 'MUSIC_NOT_FOUND',
    message: '음악을 찾을 수 없습니다.',
  ),
  INCOMPLETE_REGISTRATION(
    httpStatus: 400,
    code: 'INCOMPLETE_REGISTRATION',
    message: '회원가입이 완료되지 않았습니다.',
  ),
  INVALID_TOKEN(
    httpStatus: 401,
    code: 'INVALID_TOKEN',
    message: '유효하지 않은 토큰입니다.',
  ),
  TOKEN_REQUIRED(httpStatus: 401, code: 'TOKEN_REQUIRED', message: '토큰이 없습니다.'),
  TOKEN_EXPIRED(
    httpStatus: 402,
    code: 'TOKEN_EXPIRED',
    message: '토큰이 만료되었습니다.',
  ),
  REFRESH_TOKEN_EXPIRED(
    httpStatus: 499,
    code: 'REFRESH_TOKEN_EXPIRED',
    message: '리프레시 토큰이 만료되었습니다.',
  ),
  REFRESH_TOKEN_INVALID(
    httpStatus: 499,
    code: 'REFRESH_TOKEN_INVALID',
    message: '리프레시 토큰이 잘못되었습니다.',
  ),
  REFRESH_TOKEN_VERIFY_FAILED(
    httpStatus: 499,
    code: 'REFRESH_TOKEN_VERIFY_FAILED',
    message: '리프레시 토큰 검증이 실패했습니다.',
  ),
  FORBIDDEN(httpStatus: 403, code: 'FORBIDDEN', message: '권한이 없습니다.'),
  UNKNOWN_ERROR(
    // Fallback for unrecognized codes or general server errors
    httpStatus: 500,
    code: 'UNKNOWN_ERROR',
    message: '알 수 없는 서버 오류입니다.',
  );

  final int httpStatus;
  final String code;
  final String message;

  const ErrorCode({
    required this.httpStatus,
    required this.code,
    required this.message,
  });

  /// Factory constructor to create a [ErrorCode] from a string code.
  ///
  /// Returns [ErrorCode.UNKNOWN_ERROR] if the [codeString] is null or not recognized.
  static ErrorCode fromCode(String? codeString) {
    if (codeString == null) {
      return ErrorCode.UNKNOWN_ERROR;
    }
    for (final value in values) {
      if (value.code == codeString) {
        return value;
      }
    }
    return ErrorCode.UNKNOWN_ERROR;
  }
}
