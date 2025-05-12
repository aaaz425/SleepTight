import 'package:app/core/error/api_exception.dart';
import 'package:app/core/network/api_error_handler.dart';
import 'package:app/core/network/api_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

class DioClient {
  late final Dio _dio;

  DioClient({
    required ApiErrorHandler apiErrorHandler,
    required ProviderContainer container,
  }) {
    final options = BaseOptions(
      baseUrl: '${AppConfig.baseUrl}/${AppConfig.apiVersion}',
      connectTimeout: Duration(milliseconds: 10000),
      receiveTimeout: Duration(milliseconds: 10000),
    );

    _dio = Dio(options);

    _dio.interceptors.add(
      CustomApiInterceptor(
        dioInstance: _dio,
        apiErrorHandler: apiErrorHandler,
        container: container,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  Dio get dio => _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: '데이터 처리 중 오류: ${e.toString()}');
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    // 여기에 post data debugPrint를 추가해줘.
    debugPrint('POST DATA: $path $data $queryParameters');
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: '데이터 처리 중 오류: ${e.toString()}');
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: '데이터 처리 중 오류: ${e.toString()}');
    }
  }

  Future<T> delete<T>(
    String path, {
    dynamic data, // DELETE 요청은 본문을 가질 수 있지만, 일반적이지는 않습니다.
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson, // DELETE 응답에 본문이 있는 경우
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      // DELETE 요청의 경우 응답 데이터가 없거나 다를 수 있으므로, fromJson 처리에 유의합니다.
      // 보통 성공 시 200 OK 또는 204 No Content를 반환합니다.
      // 204 No Content의 경우 response.data가 null일 수 있습니다.
      if (fromJson != null && response.data != null) {
        return fromJson(response.data);
      }
      // T가 dynamic이거나 nullable 타입이면 null을 허용할 수 있습니다.
      // 만약 T가 non-nullable이고 response.data가 null이면, 적절한 기본값을 반환하거나 예외를 발생시켜야 합니다.
      return response.data as T;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: '데이터 처리 중 오류: ${e.toString()}');
    }
  }
}
