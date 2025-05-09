import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import './api_error_handler.dart';

class CustomApiInterceptor extends Interceptor {
  final ApiErrorHandler _apiErrorHandler = ApiErrorHandler();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\nDATA: ${response.data}',
    );

    if (response.data is Map<String, dynamic>) {
      final responseData = response.data as Map<String, dynamic>;
      if (responseData.containsKey('code') && responseData.containsKey('message')) {
        final String errorMessage = responseData['message'] as String? ?? '알 수 없는 오류 데이터입니다.';
        _apiErrorHandler.reportError(errorMessage);

        final apiException = ApiException(
          message: errorMessage,
          statusCode: response.statusCode,
          errorData: responseData,
        );
        return handler.reject(DioException(
          requestOptions: response.requestOptions,
          error: apiException,
          response: response,
          type: DioExceptionType.badResponse,
        ));
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}\nMESSAGE: ${err.message}\nDATA: ${err.response?.data}',
    );

    final apiException = ApiException.fromDioError(err);
    _apiErrorHandler.reportError(apiException.message);

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

class DioClient {
  late final Dio _dio;

  DioClient() {
    final options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 10000),
    );
    _dio = Dio(options);

    _dio.interceptors.add(CustomApiInterceptor());

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (object) => debugPrint(object.toString()),
      ));
    }
  }

  Dio get dio => _dio;

  Future<T> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
      T Function(dynamic json)? fromJson}) async {
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

  Future<T> post<T>(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      T Function(dynamic json)? fromJson}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
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
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorData;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorData,
  });

  factory ApiException.fromDioError(DioException dioError) {
    if (dioError.error is ApiException) {
      return dioError.error as ApiException;
    }

    String errorMessage = '알 수 없는 오류가 발생했습니다.';
    dynamic errorDetail = dioError.response?.data ?? dioError.error;

    if (errorDetail is Map<String, dynamic> &&
        errorDetail.containsKey('code') &&
        errorDetail.containsKey('message')) {
      errorMessage = errorDetail['message'] as String? ?? '알 수 없는 오류 데이터입니다.';
    } else {
      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = '서버 연결 시간이 초과되었습니다.';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = '요청 전송 시간이 초과되었습니다.';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = '응답 수신 시간이 초과되었습니다.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = _handleStatusCode(dioError.response?.statusCode, errorDetail);
          break;
        case DioExceptionType.cancel:
          errorMessage = 'API 요청이 취소되었습니다.';
          break;
        case DioExceptionType.connectionError:
          if (dioError.message?.contains('SocketException') ?? false) {
            errorMessage = '인터넷 연결을 확인해주세요.';
          } else if (dioError.message?.contains('HandshakeException') ?? false) {
            errorMessage = '서버와의 보안 연결에 실패했습니다 (SSL 핸드셰이크 오류).';
          } else {
            errorMessage = '네트워크 연결 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
          }
          break;
        case DioExceptionType.unknown:
        default:
          if (dioError.message?.contains('SocketException') ?? false) {
            errorMessage = '인터넷에 연결할 수 없습니다. 네트워크 상태를 확인해주세요.';
          } else if (errorDetail is String && errorDetail.isNotEmpty) {
            errorMessage = errorDetail;
          } else {
            errorMessage = dioError.message ?? '예기치 않은 오류가 발생했습니다.';
          }
          break;
      }
    }

    return ApiException(
      message: errorMessage,
      statusCode: dioError.response?.statusCode,
      errorData: dioError.response?.data,
    );
  }

  static String _handleStatusCode(int? statusCode, dynamic error) {
    if (error is Map && error.containsKey('message') && error['message'] is String) {
      return error['message'] as String;
    } else if (error is String && error.isNotEmpty) {
      return error;
    }

    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다. (400)';
      case 401:
        return '인증되지 않은 사용자입니다. (401)';
      case 402:
        return '토큰이 만료되었습니다. (402)';
      case 403:
        return '접근이 금지되었습니다. (403)';
      case 404:
        return '요청하신 정보를 찾을 수 없습니다. (404)';
      case 409:
        return '요청이 서버의 현재 상태와 충돌합니다. (409)';
      case 422:
        return '요청 본문이 유효하지 않습니다. (422)';
      case 499:
        return '토큰 갱신 관련 오류가 발생했습니다. (499)';
      case 500:
        return '서버 내부 오류가 발생했습니다. 잠시 후 다시 시도해주세요. (500)';
      case 502:
        return '게이트웨이 오류가 발생했습니다. (502)';
      case 503:
        return '서버가 일시적으로 요청을 처리할 수 없습니다. (503)';
      default:
        return '알 수 없는 서버 오류가 발생했습니다. 상태 코드: $statusCode';
    }
  }

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? " (상태 코드: $statusCode)" : ""}';
  }
}
