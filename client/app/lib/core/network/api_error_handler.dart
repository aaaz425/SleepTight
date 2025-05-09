import 'dart:async';

/// API 에러 발생 시 UI에 알리기 위한 이벤트 데이터 클래스입니다.
/// 필요에 따라 추가 정보를 포함하도록 확장할 수 있습니다. (예: 에러 타입, 특정 코드 등)
class ApiErrorEvent {
  final String message;

  ApiErrorEvent(this.message);
}

/// API 에러를 중앙에서 처리하고 UI에 알림을 보내는 싱글톤 서비스 클래스입니다.
class ApiErrorHandler {
  // приватный конструктор для синглтона (싱글톤을 위한 private 생성자)
  ApiErrorHandler._privateConstructor();
  static final ApiErrorHandler _instance = ApiErrorHandler._privateConstructor();

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
  void reportError(String message) {
    _errorController.add(ApiErrorEvent(message));
    // 디버깅 또는 로깅 목적으로 콘솔에 출력할 수 있습니다.
    // print('ApiErrorHandler: Error reported - $message');
  }

  /// StreamController를 닫습니다. 앱이 종료될 때 호출될 수 있으나, 
  /// 싱글톤이고 앱 생명주기 동안 계속 사용된다면 필수는 아닐 수 있습니다.
  /// 하지만 좋은 습관으로 `dispose` 메서드를 만들어두는 것이 좋습니다.
  void dispose() {
    _errorController.close();
  }
}
