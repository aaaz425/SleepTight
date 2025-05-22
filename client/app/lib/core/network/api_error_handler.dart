import 'dart:async';
import 'package:sleep_tight/core/error/api_exception.dart';

/// API 에러 발생 시 UI에 알리기 위한 이벤트 데이터 클래스입니다.
/// 필요에 따라 추가 정보를 포함하도록 확장할 수 있습니다. (예: 에러 타입, 특정 코드 등)
class ApiErrorEvent {
  final ApiException apiException;

  ApiErrorEvent(this.apiException);
}

/// API 에러를 중앙에서 처리하고 UI에 알림을 보내는 싱글톤 서비스 클래스입니다.
class ApiErrorHandler {
  // 싱글톤(Singleton) 구현: 앱 전체에서 단 하나의 인스턴스만 생성되도록 보장
  ApiErrorHandler._privateConstructor();
  static final ApiErrorHandler _instance =
      ApiErrorHandler._privateConstructor();

  /// `ApiErrorHandler`의 싱글톤 인스턴스를 반환합니다.
  factory ApiErrorHandler() {
    return _instance;
  }

  // 에러 이벤트를 위한 StreamController. broadcast로 여러 리스너가 구독할 수 있도록 합니다.
  final _errorController = StreamController<ApiErrorEvent>.broadcast();

  /// 에러 이벤트를 구독할 수 있는 Stream입니다.
  /// UI 계층(예: main.dart 또는 최상위 위젯)에서 이 Stream을 listen하여 에러 메시지를 받습니다.
  Stream<ApiErrorEvent> get onError => _errorController.stream;

  /// 에러가 발생했음을 알립니다.
  /// 이 메서드가 호출되면 `onError` Stream으로 `ApiErrorEvent`가 전달됩니다.
  void reportError(ApiException apiException) {
    _errorController.add(ApiErrorEvent(apiException));
    // 디버깅 또는 로깅 목적으로 콘솔에 출력할 수 있습니다.
    // print('ApiErrorHandler: Error reported - ${apiException.message}');
  }

  /// StreamController를 닫습니다.
  void dispose() {
    _errorController.close();
  }
}
