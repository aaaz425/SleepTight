import 'package:sleep_tight/core/error/api_exception.dart';
import 'package:sleep_tight/features/auth/presentation/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './api_error_handler.dart';

class CustomApiInterceptor extends Interceptor {
  final Dio dioInstance;
  final ApiErrorHandler apiErrorHandler;
  final ProviderContainer container;

  CustomApiInterceptor({
    required this.dioInstance,
    required this.apiErrorHandler,
    required this.container,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken =
        await container.read(authRepositoryProvider).getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint('ERROR TEST: ${err.toString()}');

    // 499: 로그아웃 처리
    if (err.response?.statusCode == 499) {
      debugPrint('499: 로그아웃 처리');
      await container.read(authRepositoryProvider).clearTokenAndStatus();
      container.read(authStateProvider.notifier).refreshAuthStatus();
      final apiException = ApiException.fromDioError(err);
      apiErrorHandler.reportError(apiException);
      return handler.reject(err);
    }

    // 402: refresh token으로 access token 재발급 시도
    if (err.response?.statusCode == 402 &&
        !err.requestOptions.extra.containsKey('isRetryAttempted')) {
      debugPrint('402: 토큰 재발급 시도');
      err.requestOptions.extra['isRetryAttempted'] = true;
      try {
        await container.read(authRepositoryProvider).refreshAccessToken();
        // 토큰 재발급 성공 시 원래 요청 재시도
        final response = await dioInstance.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        debugPrint('토큰 재발급 실패: $e');
        // 실패 시 로그아웃 처리
        await container.read(authRepositoryProvider).clearTokenAndStatus();
        container.read(authStateProvider.notifier).refreshAuthStatus();
        final apiException = ApiException.fromDioError(err);
        apiErrorHandler.reportError(apiException);
        return handler.reject(err);
      }
    }

    // 기타 에러 처리
    final apiException = ApiException.fromDioError(err);
    apiErrorHandler.reportError(apiException);

    final newDioException = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
      message: err.message,
    );

    return handler.reject(newDioException);
  }
}
