import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';
import 'core/config/router.dart';
import 'core/config/theme.dart';
import 'core/network/api_error_handler.dart';

// GoRouter에 전달할 NavigatorKey를 앱의 상위 레벨에 정의합니다.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  // ProviderScope로 앱을 감싸 Riverpod을 사용할 수 있도록 합니다.
  runApp(const ProviderScope(child: SleepTightApp()));
}

// StatelessWidget을 ConsumerWidget으로 변경합니다.
class SleepTightApp extends ConsumerWidget {
  const SleepTightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // apiErrorStreamProvider를 listen하여 에러 발생 시 토스트 메시지 표시
    ref.listen<AsyncValue<ApiErrorEvent>>(apiErrorStreamProvider, (
      previous,
      next,
    ) {
      next.whenData((apiErrorEvent) {
        final currentContext = navigatorKey.currentContext;
        if (currentContext != null) {
          toastification.show(
            context: currentContext,
            title: Text(apiErrorEvent.message),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 5),
            alignment: Alignment.bottomCenter,
          );
        }
      });
    });

    // goRouterProvider를 watch하여 GoRouter 인스턴스를 가져옵니다.
    // 이때, 생성한 navigatorKey를 전달합니다.
    final appRouter = ref.watch(goRouterProvider(navigatorKey));

    return MaterialApp.router(
      title: 'Sleep Tight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // routerConfig에 watch를 통해 얻은 appRouter 인스턴스를 전달합니다.
      routerConfig: appRouter,
    );
  }
}
