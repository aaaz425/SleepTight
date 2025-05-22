export const ExceptionCode = {
  USER_NOT_FOUND: {
    status: 400,
    code: 'USER_NOT_FOUND',
    message: '유저를 찾을 수 없습니다.',
  },
  MUSIC_NOT_FOUND: {
    status: 400,
    code: 'MUSIC_NOT_FOUND',
    message: '음악을 찾을 수 없습니다.',
  },
  ACTIVITY_DATA_NOT_FOUND: {
    status: 400,
    code: 'ACTIVITY_DATA_NOT_FOUND',
    message: '활동데이터를 찾을 수 없습니다.',
  },
  INCOMPLETE_REGISTRATION: {
    status: 400,
    code: 'INCOMPLETE_REGISTRATION',
    message: '회원가입이 완료되지 않았습니다.',
  },
  DUPLICATE_SEGMENT_ID: {
    status: 400,
    code: 'DUPLICATE_SEGMENT_ID',
    message: '이미 존재하는 세그먼트 아이디입니다.',
  },
  REPORT_NOT_FOUND: {
    status: 404,
    code: 'REPORT_NOT_FOUND',
    message: '수면 리포트를 찾을 수 없습니다.',
  },
  INVALID_TOKEN: {
    status: 401,
    code: 'INVALID_TOKEN',
    message: '유효하지 않은 토큰입니다.',
  },
  TOKEN_REQUIRED: {
    status: 401,
    code: 'TOKEN_REQUIRED',
    message: '토큰이 없습니다.',
  },
  TOKEN_EXPIRED: {
    status: 402,
    code: 'TOKEN_EXPIRED',
    message: '토큰이 만료되었습니다.',
  },
  REFRESH_TOKEN_EXPIRED: {
    status: 499,
    code: 'REFRESH_TOKEN_EXPIRED',
    message: '리프레시 토큰이 만료되었습니다.',
  },
  REFRESH_TOKEN_INVALID: {
    status: 499,
    code: 'REFRESH_TOKEN_INVALID',
    message: '리프레시 토큰이 잘못되었습니다.',
  },
  REFRESH_TOKEN_VERIFY_FAILED: {
    status: 499,
    code: 'REFRESH_TOKEN_VERIFY_FAILED',
    message: '리프레시 토큰 검증이 실패했습니다.',
  },
  FORBIDDEN: { status: 403, code: 'FORBIDDEN', message: '권한이 없습니다.' },
  // 추가 가능
} as const;

export type ExceptionCodeKey = keyof typeof ExceptionCode;
