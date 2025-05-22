import 'package:flutter/foundation.dart' show immutable, kDebugMode;

/// API 응답의 데이터 페이로드를 위한 제네릭 클래스입니다.
///
/// API 레벨의 에러(예: 응답 본문의 `success: false`)는
/// 인터셉터에 의해 `ApiException`으로 변환되어 처리되었다고 가정합니다.
/// 이 클래스는 성공적인 응답의 `data` 부분만을 나타냅니다.
/// [T]는 데이터 페이로드의 타입입니다.
@immutable
class ApiResponse<T> {
  /// 데이터 페이로드입니다.
  /// 엔드포인트가 데이터를 반환하지 않거나 명시적으로 null인 경우 null일 수 있습니다.
  final T? data;

  const ApiResponse({this.data});

  /// JSON 맵으로부터 [ApiResponse]를 생성합니다.
  ///
  /// [json]: 'data' 필드를 포함할 것으로 예상되는 JSON 맵입니다.
  /// [fromJsonData]: JSON의 'data' 부분을 [T] 타입의 객체로 변환하는 함수입니다.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Object? jsonData)? fromJsonData,
  }) {
    T? responseData;

    if (json.containsKey('data')) {
      final jsonData = json['data'];
      if (fromJsonData != null) {
        // 사용자 정의 파서가 제공된 경우
        responseData = fromJsonData(jsonData);
      } else {
        // 사용자 정의 파서가 없는 경우, 직접 할당 시도
        if (jsonData == null) {
          // jsonData가 null일 때, T가 nullable 타입이어야 responseData에 null 할당 가능
          try {
            responseData = null as T;
          } catch (e) {
            // T가 non-nullable인데 jsonData가 null인 경우 캐스트 오류 발생
            if (kDebugMode) {
              print(
                'ApiResponse.fromJson: json[\'data\'] is null, but type $T is not nullable. Error: $e',
              );
            }
            // responseData는 null로 유지되거나, 필요시 예외를 다시 던질 수 있습니다.
          }
        } else {
          // jsonData가 null이 아닌 경우, 직접 캐스트 시도
          try {
            responseData = jsonData as T;
          } catch (e) {
            // 직접 캐스트 실패 (주로 T가 복합 객체이고 jsonData를 특정 방식으로 파싱해야 할 때)
            if (kDebugMode) {
              print(
                'ApiResponse.fromJson: Failed to cast json[\'data\'] to type $T directly. Consider providing a fromJsonData function for complex types. Error: $e',
              );
            }
            responseData = null; // 또는 적절히 처리 (예: 예외 다시 던지기)
          }
        }
      }
    }
    // 'data' 키가 없는 경우 responseData는 null로 유지됩니다.

    return ApiResponse<T>(data: responseData);
  }

  @override
  String toString() {
    return 'ApiResponse(data: $data)';
  }
}
