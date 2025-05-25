import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/theme.dart';
import 'package:sleep_tight/core/error/api_exception.dart';
import 'package:sleep_tight/core/service/fcm_messaging_service.dart';
import 'package:sleep_tight/core/storage/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleep_tight/features/music/presentation/providers/audio_controller.dart';
import 'package:sleep_tight/features/music/presentation/widgets/fullscreen_player.dart';
import 'package:sleep_tight/features/music/presentation/widgets/mini_player.dart';
import 'package:toastification/toastification.dart';
import 'package:sleep_tight/core/config/router.dart';
import 'core/network/api_error_handler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sleep_tight/features/health/services/wear_communication_service.dart';
import 'firebase_options.dart';

// GoRouter에 전달할 NavigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// WearCommunicationService Provider
final wearCommunicationServiceProvider = Provider<WearCommunicationService>((
  ref,
) {
  return WearCommunicationService();
});

// ApiErrorHandler Provider
final apiErrorHandlerProvider = Provider<ApiErrorHandler>((ref) {
  return ApiErrorHandler();
});

// ApiErrorEvent StreamProvider
final apiErrorStreamProvider = StreamProvider<ApiErrorEvent>((ref) {
  final errorHandler = ref.watch(apiErrorHandlerProvider);
  return errorHandler.onError;
});

// Miniplayer의 확장/축소 진행 상태를 공유하기 위한 ValueNotifier Provider
final playerExpandProgressProvider = Provider<ValueNotifier<double>>((ref) {
  final notifier = ValueNotifier<double>(0.0); // 초기값 0.0 (최소화 상태)
  ref.onDispose(notifier.dispose);
  return notifier;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  await FcmService.initFCM();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Caught Flutter error: ${details.exception}');
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColors.gray01,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await initializeDateFormatting('ko_KR', null);
  final sharedPreferences = await SharedPreferences.getInstance();
  await dotenv.load(fileName: ".env");
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

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
    final appRouter = ref.watch(goRouterProvider(navigatorKey));
    final audioState = ref.watch(audioControllerProvider);
    final bool showMiniplayer = audioState.music != null;

    final playerExpandProgress = ref.watch(playerExpandProgressProvider);

    const double miniPlayerMinHeight = 52.0;
    // BottomNavigationBar의 표준 높이 (Miniplayer가 이를 덮도록 배치될 것임)
    // const double bottomNavBarHeight = kBottomNavigationBarHeight; // 이 값은 Miniplayer 위치 계산에 직접 사용되지는 않음

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWearCommunication(ref);
    });

    ref.listen<AsyncValue<ApiErrorEvent>>(apiErrorStreamProvider, (
      previous,
      next,
    ) {
      next.whenData((apiErrorEvent) {
        final overlayContext = navigatorKey.currentState?.overlay?.context;
        if (overlayContext != null) {
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
            alignment: Alignment.topCenter,
            autoCloseDuration: const Duration(seconds: 4),
            borderRadius: BorderRadius.circular(12.0),
            applyBlurEffect: true,
            showIcon: false,
          );
        }
      });
    });

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Sleep Tight',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: appRouter,
        builder: (context, routerWidget) {
          return Stack(
            children: [
              if (routerWidget != null) routerWidget,

              if (showMiniplayer)
                ValueListenableBuilder<double>(
                  valueListenable: playerExpandProgress,
                  builder: (context, percentage, _) {
                    final bool isMinimized = percentage < 0.05;
                    debugPrint(
                      'ValueListenableBuilder - percentage: $percentage, isMinimized: $isMinimized',
                    );

                    if (isMinimized) {
                      // 최소화 상태일 때: 우리가 직접 만든 MiniPlayer 위젯
                      return Positioned(
                        left: 0,
                        right: 0,
                        bottom: kBottomNavigationBarHeight,
                        height: miniPlayerMinHeight,
                        child: MiniPlayer(), // 사용자의 커스텀 MiniPlayer 위젯
                      );
                    } // ValueListenableBuilder의 else 블록 예시 (제안하신 방식)
                    else {
                      // isMinimized == false, 즉 percentage >= 0.05
                      // 여기서 FullScreenPlayer를 표시합니다.
                      // 하지만 부드러운 높이 애니메이션과 아래로 드래그하여 닫는 기능을 직접 구현해야 합니다.

                      final screenHeight = MediaQuery.of(context).size.height;
                      // playerExpandProgress.value를 기반으로 FullScreenPlayer의 현재 높이를 계산합니다.
                      // (0.0 = 최소 높이 근처, 1.0 = 전체 화면 높이)
                      // 이것은 Miniplayer 패키지가 내부적으로 수행하는 애니메이션을 단순화한 버전입니다.

                      if (percentage >= 0.05) {
                        // 실제로 보여줄 조건
                        return Positioned.fill(
                          child: GestureDetector(
                            // FullScreenPlayer를 아래로 드래그하여 닫는 기능 추가
                            onVerticalDragUpdate: (details) {
                              // playerExpandProgress.value를 감소시키는 로직 (mini_player.dart의 로직과 유사하지만 아래 방향)
                              final playerNotifier = ref.read(
                                playerExpandProgressProvider,
                              );
                              double dragDelta =
                                  details.delta.dy; // 아래로 드래그 시 양수
                              double changeInPercentage =
                                  dragDelta / (screenHeight * 0.7); // 민감도 조절
                              playerNotifier.value = (playerNotifier.value +
                                      changeInPercentage)
                                  .clamp(0.0, 1.0);
                            },
                            onVerticalDragEnd: (details) {
                              // 드래그가 끝나면 특정 조건에 따라 닫거나 다시 확장
                              final playerNotifier = ref.read(
                                playerExpandProgressProvider,
                              );
                              if (playerNotifier.value < 0.6 &&
                                  (details.primaryVelocity ?? 0) > 300) {
                                // 충분히 아래로 빠르게 드래그했거나, 특정 지점 이하로 드래그
                                playerNotifier.value = 0.0; // 닫기 (최소화 상태로)
                              } else if (playerNotifier.value < 0.05) {
                                // 거의 닫힌 상태면 확실히 닫기
                                playerNotifier.value = 0.0;
                              } else {
                                // 애매한 위치에 놓으면 다시 완전히 확장 (또는 현재 위치 유지 - 정책에 따라)
                                // playerNotifier.value = 1.0; // 이 부분은 사용자 경험에 맞게 조절 필요
                              }
                            },
                            child: FullscreenPlayer(),
                          ),
                        );
                      } else {
                        // percentage가 0.05 미만으로 다시 내려가면 (이론적으로는 isMinimized가 true가 됨)
                        return const SizedBox.shrink();
                      }
                    }
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _initializeWearCommunication(WidgetRef ref) async {
  final wearService = ref.read(wearCommunicationServiceProvider);
  await wearService.initialize();
  debugPrint("Wear OS Communication Initialized");
}
