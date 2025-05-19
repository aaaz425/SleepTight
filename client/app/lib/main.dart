import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/theme.dart';
import 'package:sleep_tight/core/error/api_exception.dart';
import 'package:sleep_tight/core/storage/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:sleep_tight/core/config/router.dart';
import 'core/network/api_error_handler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sleep_tight/features/health/services/wear_communication_service.dart';

// GoRouter에 전달할 NavigatorKey를 앱의 상위 레벨에 정의합니다.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// WearCommunicationService 인스턴스를 제공하는 Provider
final wearCommunicationServiceProvider = Provider<WearCommunicationService>((
  ref,
) {
  return WearCommunicationService();
});

// ApiErrorHandler 인스턴스를 제공하는 Provider
final apiErrorHandlerProvider = Provider<ApiErrorHandler>((ref) {
  return ApiErrorHandler();
});

// ApiErrorHandler의 onError 스트림을 제공하는 StreamProvider
// ApiErrorEvent 타입을 명시해주는 것이 좋습니다. (ApiErrorEvent가 정의되어 있다고 가정)
final apiErrorStreamProvider = StreamProvider<ApiErrorEvent>((ref) {
  final errorHandler = ref.watch(apiErrorHandlerProvider);
  return errorHandler.onError;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 세로모드로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 상태바, 네비게이션바 색상
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColors.gray01,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // TODO: 로컬라이제이션 추가
  await initializeDateFormatting('ko_KR', null);

  final sharedPreferences = await SharedPreferences.getInstance();

  // 반드시 dotenv.load()를 먼저 호출!
  await dotenv.load(fileName: ".env");

  // 그 다음에 KakaoSdk.init 등 환경변수 사용 코드 작성
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

  // 여기서 secureStorage에 accessToken이 있는지 확인하고
  // 이 token을 통해 회원정보를 제대로 가져오는지 확인하고
  // 잘 가져오면 /home으로 이동
  // 잘 가져오지 않으면 로그아웃 처리.

  // ProviderScope로 앱을 감싸 Riverpod을 사용할 수 있도록 합니다.
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: SleepTightApp(),
    ),
  );
}

class SleepTightApp extends ConsumerWidget {
  const SleepTightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("sleeptightapp started");
    // Wear OS 통신 서비스 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWearCommunication(ref);
    });

    // apiErrorStreamProvider를 listen하여 에러 발생 시 토스트 메시지 표시
    ref.listen<AsyncValue<ApiErrorEvent>>(apiErrorStreamProvider, (
      previous, // 이전 상태(nullable)
      next, // 현재 상태
    ) {
      next.whenData((apiErrorEvent) {
        // final currentContext = navigatorKey.currentContext;
        final overlayContext = navigatorKey.currentState?.overlay?.context;
        if (overlayContext != null) {
          // ApiErrorEvent에서 ApiException 객체를 추출합니다.
          final apiException = apiErrorEvent.apiException;

          toastification.show(
            context: overlayContext,
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            title: Text(
              ApiException.handleStatusCode(
                apiException.httpStatusCode,
                apiException.errorData,
              ),
            ),
            alignment: Alignment.bottomCenter,
            autoCloseDuration: const Duration(seconds: 4),
            borderRadius: BorderRadius.circular(12.0),
            applyBlurEffect: true,
            showIcon: false,
          );
        }
      });
    });

    // goRouterProvider를 watch하여 GoRouter 인스턴스를 가져옵니다.
    // 이때, 생성한 navigatorKey를 전달합니다.
    final appRouter = ref.watch(goRouterProvider(navigatorKey));

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Sleep Tight',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: appRouter,
      ),
    );
  }

  // Wear OS 통신 초기화
  Future<void> _initializeWearCommunication(WidgetRef ref) async {
    final wearService = ref.read(wearCommunicationServiceProvider);
    await wearService.initialize();
  }
}
