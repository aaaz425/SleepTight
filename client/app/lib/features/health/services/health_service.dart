import 'dart:async';
import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();
  bool _isConfigured = false; // To track if configure() has been called

  // 활동 데이터 타입 정의
  static final _activityTypes = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.HEART_RATE,
    HealthDataType.HEIGHT,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.WATER,
    HealthDataType.WORKOUT,
    HealthDataType.LEAN_BODY_MASS,
  ];

  // 수면 데이터 타입 정의
  static final _sleepDataTypes = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
  ];

  // Helper to ensure Health plugin is configured
  Future<void> _ensureConfigured() async {
    if (!_isConfigured) {
      try {
        // Health Connect 사용 가능하면 사용하도록 설정 (Android 해당)
        await _health.configure();
        _isConfigured = true;
      } catch (e) {
        // 앱의 에러 처리 전략에 따라 여기서 오류를 다시 던지거나 상태를 설정할 수 있습니다.
      }
    }
  }

  // 활동 데이터 가져오기
  Future<List<HealthDataPoint>> fetchActivityData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _ensureConfigured();
    if (!_isConfigured) {
      print("HealthService: 설정 실패, 활동 데이터를 가져올 수 없습니다.");
      return [];
    }

    List<HealthDataPoint> activityData = [];
    bool permissionsGranted = false;

    try {
      // 데이터를 읽기 전에 데이터 유형에 대한 액세스 요청
      permissionsGranted = await _health.requestAuthorization(_activityTypes);
    } catch (e) {
      print("활동 유형에 대한 권한 요청 중 오류 발생: $e");
      return []; // 권한 오류 시 빈 목록 반환
    }

    if (permissionsGranted) {
      try {
        activityData = await _health.getHealthDataFromTypes(
          types: _activityTypes,
          startTime: startDate,
          endTime: endDate,
        );
        activityData = _health.removeDuplicates(activityData);
      } catch (error) {
        print("활동 데이터 가져오기 실패: $error");
      }
    } else {
      print("활동 데이터에 대한 접근 권한이 거부되었습니다.");
    }
    return activityData;
  }

  // 수면 데이터 가져오기
  Future<List<HealthDataPoint>> fetchSleepData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _ensureConfigured();
    if (!_isConfigured) {
      print("HealthService: 설정 실패, 수면 데이터를 가져올 수 없습니다.");
      return [];
    }

    List<HealthDataPoint> sleepData = [];
    bool permissionsGranted = false;

    try {
      // 데이터를 읽기 전에 데이터 유형에 대한 액세스 요청
      permissionsGranted = await _health.requestAuthorization(_sleepDataTypes);
    } catch (e) {
      print("수면 유형에 대한 권한 요청 중 오류 발생: $e");
      return []; // 권한 오류 시 빈 목록 반환
    }

    if (permissionsGranted) {
      try {
        sleepData = await _health.getHealthDataFromTypes(
          types: _sleepDataTypes,
          startTime: startDate,
          endTime: endDate,
        );
        print("SLEEP_DATA: $sleepData");
        sleepData = _health.removeDuplicates(sleepData);
        print("SLEEP_DATA: $sleepData");
      } catch (error) {
        print("수면 데이터 가져오기 실패: $error");
      }
    } else {
      print("수면 데이터에 대한 접근 권한이 거부되었습니다.");
    }
    return sleepData;
  }

  /// 활동 및 수면 데이터를 문자열로 포맷하여 반환합니다.
  Future<String> getHealthDataAsString() async {
    await _ensureConfigured();
    if (!_isConfigured) {
      return "HealthService: 설정 실패, 데이터를 문자열로 변환할 수 없습니다.";
    }

    StringBuffer sb = StringBuffer();
    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 1)); // 지난 24시간

    sb.writeln(
      "===== 활동 데이터 (${startDate.toIso8601String()} - ${endDate.toIso8601String()}) =====",
    );
    try {
      List<HealthDataPoint> activityData = await fetchActivityData(
        startDate,
        endDate,
      );
      if (activityData.isEmpty) {
        sb.writeln("지난 24시간 동안의 활동 데이터가 없습니다.");
      } else {
        for (HealthDataPoint p in activityData) {
          sb.writeln("{$p.toString()}");
        }
      }
    } catch (e) {
      sb.writeln("활동 데이터 조회 중 오류: $e");
    }

    sb.writeln(
      "\n===== 수면 데이터 (${startDate.toIso8601String()} - ${endDate.toIso8601String()}) =====",
    );
    try {
      List<HealthDataPoint> sleepData = await fetchSleepData(
        startDate,
        endDate,
      );
      if (sleepData.isEmpty) {
        sb.writeln("지난 24시간 동안의 수면 데이터가 없습니다.");
      } else {
        for (HealthDataPoint p in sleepData) {
          sb.writeln("{$p.toString()}");
        }
      }
    } catch (e) {
      sb.writeln("수면 데이터 조회 중 오류: $e");
    }

    return sb.toString();
  }

  // 데이터를 콘솔에 출력 (이제 getHealthDataAsString 사용)
  Future<void> printData() async {
    print("HealthService: 데이터 가져오기 및 콘솔 출력 시도...");
    String dataString = await getHealthDataAsString();
    print(dataString);
    print("HealthService: 데이터 콘솔 출력 완료.");
  }
}
