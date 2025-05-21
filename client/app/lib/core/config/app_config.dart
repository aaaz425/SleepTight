class AppConfig {
  // 기본 URL은 유지합니다.
  static const String baseUrl = "https://k12s303.p.ssafy.io";

  // API 버전을 위한 상수 (필요한 경우)
  static const String apiVersion = "api";

  static final Routes routes = Routes();
  static final ApiPaths api = ApiPaths();
}

class Routes {
  Routes();

  // Initial & Auth Routes
  final String welcome = '/welcome';
  final String appInit = '/app-init';
  final String signUp = '/signup';
  final String onboarding = '/onboarding';
  final String sayGoodbye = '/say-goodbye';

  // Main Application Routes (Bottom Navigation)
  final String home = '/home';
  final String homeSleeping = '/home/sleeping';

  final String sleepAnalysis = '/sleep-analysis';
  final String sleepCoach = '/sleep-coach';
  final String sound = '/sound';

  // MyPage Routes
  final String mypage = '/mypage';
  final String mypageInfo = '/mypage/info';
  final String mypageInfoName = '/mypage/info/name';
  final String mypageInfoBirthDate = '/mypage/info/birth-date';
  final String mypageInfoGender = '/mypage/info/gender';
  final String mypageInfoNationality = '/mypage/info/nationality';
  final String mypageInfoOauth = '/mypage/info/oauth';
  final String mypageInfoLogout = '/mypage/info/logout';
  final String mypageInfoWithdraw = '/mypage/info/withdraw';
  final String mypageInfoWithdrawConfirmation =
      '/mypage/info/withdraw-confirmation';

  final String mypageBody = '/mypage/body';
  final String mypageBodyHeight = '/mypage/body/height';
  final String mypageBodyWeight = '/mypage/body/weight';

  final String mypageSleepTime = '/mypage/sleep-time';
  final String mypagePush = '/mypage/push';
  final String mypageAppInfo = '/mypage/app-info';
}

// --- API Path Definitions ---
class ApiPaths {
  ApiPaths();

  // Base domains for different features (relative to /api)
  static const String _authDomain = '/auth';
  static const String _userDomain = '/user';
  static const String _sleepDomain = '/sleep';
  static const String _sleepReportsDomain = '/sleep-reports'; // For diaries
  static const String _musicDomain = '/music';

  // Accessors for each API group
  final _AuthApiPaths auth = _AuthApiPaths();
  final _UserApiPaths user = _UserApiPaths();
  final _SleepApiPaths sleep = _SleepApiPaths();
  final _MusicApiPaths music = _MusicApiPaths();
}

// --- Auth APIs ---
class _AuthApiPaths {
  _AuthApiPaths();
  String get kakao => '${ApiPaths._authDomain}/kakao'; // POST /api/auth/kakao
  String get refresh =>
      '${ApiPaths._authDomain}/refresh'; // POST /api/auth/refresh
}

// --- User APIs ---
class _UserApiPaths {
  _UserApiPaths();
  String get base => ApiPaths._userDomain; // GET api/user
  String get logout => '${ApiPaths._userDomain}/logout'; // POST api/user/logout
  String get register =>
      '${ApiPaths._userDomain}/register'; // POST api/user/register
  String get withdraw =>
      '${ApiPaths._userDomain}/withdraw'; // POST api/user/withdraw
  String get name => '${ApiPaths._userDomain}/name'; // PATCH api/user/name
  String get birthDate =>
      '${ApiPaths._userDomain}/birth-date'; // PATCH api/user/birth-date
  String get gender =>
      '${ApiPaths._userDomain}/gender'; // PATCH api/user/gender
  String get country =>
      '${ApiPaths._userDomain}/country'; // PATCH api/user/country
  String get height =>
      '${ApiPaths._userDomain}/height'; // PATCH api/user/height
  String get weight =>
      '${ApiPaths._userDomain}/weight'; // PATCH api/user/weight
  String get minSleepDuration =>
      '${ApiPaths._userDomain}/min-sleep-duration'; // PATCH api/user/min-sleep-duration
  String get sleepTime =>
      '${ApiPaths._userDomain}/sleep-time'; // PATCH api/user/sleep-time
  String get wakeTime =>
      '${ApiPaths._userDomain}/wake-time'; // PATCH api/user/wake-time
  String get sleepGoal =>
      '${ApiPaths._userDomain}/sleep-goal'; // GET api/user/sleep-goal
  String get reinstate =>
      '${ApiPaths._userDomain}/reinstate'; // PATCH api/user/reinstate
}

// --- Sleep APIs ---
class _SleepApiPaths {
  _SleepApiPaths();
  String get startSleep =>
      '${ApiPaths._sleepDomain}-report/start-sleep'; // POST api/sleep-report/start-sleep
  String get endSleep =>
      '${ApiPaths._sleepDomain}-report/end-sleep'; // POST api/sleep/end-sleep
  String get sound => '${ApiPaths._sleepDomain}-sound'; // POST api/sleep-sound
  String get events =>
      '${ApiPaths._sleepDomain}/events'; // GET api/sleep/events
  String coaching(String date) =>
      '${ApiPaths._sleepDomain}-coaching/$date'; // GET api/sleep-coaching/{date}
  String get activityData => '/activity-data'; // POST api/sleep/activity-data

  // Sleep Reports (under /sleep/report/*)
  String get reportBase =>
      '${ApiPaths._sleepDomain}/report'; // POST api/sleep/report
  String reportByDate(String date) =>
      '${ApiPaths._sleepDomain}-report/$date'; // GET api/sleep/report/{date}
  String eventsByReportId(int reportId) =>
      '${ApiPaths._sleepDomain}-report/events/$reportId'; // => GET api/sleep/report/events/{reportId}
  String get reportCalendarByMonth =>
      '${ApiPaths._sleepDomain}-report/calendar'; // GET api/sleep-report/calendar

  // Sleep Diaries (under /sleep-reports/diaries/*)
  String diaryByDate(String date) =>
      '${ApiPaths._sleepReportsDomain}/diaries/$date'; // GET api/sleep-reports/diaries/{date}
  String diaryById(int reportId) =>
      '${ApiPaths._sleepReportsDomain}/diaries/$reportId'; // GET api/sleep-reports/diaries/{reportId}
  String get updateDiary =>
      '${ApiPaths._sleepReportsDomain}/diaries'; // PATCH api/sleep-reports/diaries
}

// --- Music APIs ---
class _MusicApiPaths {
  const _MusicApiPaths();
  // GET api/music/{musicId}
  String musicById(String musicId) => '${ApiPaths._musicDomain}/$musicId';
  // GET api/music?category={category} (query param added by Dio) & POST api/music
  String get base => ApiPaths._musicDomain;
  // PATCH api/music/like & GET api/music/like
  String get like => '${ApiPaths._musicDomain}/like';
  // GET api/music/popular
  String get popular => '${ApiPaths._musicDomain}/popular';
  // POST api/music/ai & GET api/music/ai
  String get ai => '${ApiPaths._musicDomain}/ai';
}

// 예시: DioClient 또는 서비스 레이어에서 사용
// AppConfig.apiVersion (즉, "api")은 Dio의 baseUrl에 이미 포함되어 있거나,
// 인터셉터 등에서 요청 URL 앞부분에 추가된다고 가정합니다.

// Kakao 로그인 요청
// final response = await dio.post(AppConfig.api.auth.kakao, data: ...);

// 사용자 정보 가져오기
// final response = await dio.get(AppConfig.api.user.base);

// 특정 날짜의 수면 리포트 가져오기
// final response = await dio.get(AppConfig.api.sleep.reportByDate('2023-10-27'));

// 음악 좋아요 토글
// final response = await dio.patch(AppConfig.api.music.like, data: ...);
