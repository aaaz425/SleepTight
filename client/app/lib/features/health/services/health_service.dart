import 'dart:async';
import 'dart:io';
import 'package:health/health.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.NUTRITION,
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

    // Request system permissions first
    await Permission.activityRecognition.request();
    await Permission.location.request();

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

    // Request system permissions first
    await Permission.activityRecognition.request();
    await Permission.location.request();

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

      // CSV 헤더 추가
      sb.writeln(
        "uuid,value,unit,dataType,platform,dateFrom,dateTo,sourceName",
      );

      if (activityData.isEmpty) {
        sb.writeln("지난 24시간 동안의 활동 데이터가 없습니다.");
      } else {
        for (HealthDataPoint p in activityData) {
          String valueStr = "N/A"; // 기본값
          String unitDisplayStr = p.unitString; // 기본 단위 문자열

          if (p.value is NumericHealthValue) {
            // NumericHealthValue인 경우 숫자 값을 문자열로 변환
            var numVal = (p.value as NumericHealthValue).numericValue;
            valueStr = numVal.toString();
          } else if (p.value is WorkoutHealthValue) {
            var workoutHealthValue = p.value as WorkoutHealthValue; // 한번만 캐스팅
            var workoutVal = workoutHealthValue.totalEnergyBurned;
            if (workoutVal != null) {
              valueStr = workoutVal.toString();
              // totalEnergyBurnedUnit이 있으면 해당 unit의 이름을 사용, 없으면 기본 p.unitString 사용
              unitDisplayStr =
                  workoutHealthValue.totalEnergyBurnedUnit?.name ??
                  p.unitString;
            } else {
              valueStr = "N/A (Workout Energy)";
            }
          } else {
            // 기타 HealthValue 타입에 대한 처리 (필요한 경우 추가)
            valueStr = p.value.toString(); // 기본 toString() 사용
          }

          // CSV 데이터 행 추가
          sb.writeln(
            "${p.uuid}," +
                "${valueStr}," +
                "${unitDisplayStr}," + // 수정된 단위 문자열 사용
                "${p.typeString}," +
                "${p.sourcePlatform.name}," +
                "${p.dateFrom.toIso8601String()}," +
                "${p.dateTo.toIso8601String()}," +
                "${p.sourceName}",
          );
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
        // Add a header for sleep data CSV, similar to activity data
        sb.writeln(
          "UUID,Value,Unit,Type,SourcePlatform,DateFrom,DateTo,SourceName",
        );
        for (HealthDataPoint p in sleepData) {
          String valueStr = "N/A";
          String unitDisplayStr = p.unitString;

          // For sleep data, value might not always be Numeric.
          // Simple toString() for now, can be refined based on actual SleepHealthValue types.
          if (p.value is NumericHealthValue) {
            var numVal = (p.value as NumericHealthValue).numericValue;
            valueStr = numVal.toString();
          } else {
            valueStr =
                p.value.toString(); // Or a more specific property if available
          }

          sb.writeln(
            "${p.uuid}," +
                "${valueStr}," +
                "${unitDisplayStr}," +
                "${p.typeString}," +
                "${p.sourcePlatform.name}," +
                "${p.dateFrom.toIso8601String()}," +
                "${p.dateTo.toIso8601String()}," +
                "${p.sourceName}",
          );
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

  /// Fetches health data, saves it to a temporary .txt file, and shares it.
  Future<void> exportHealthDataAsTxt() async {
    try {
      print("HealthService: 데이터 TXT 파일로 내보내기 시작...");
      String dataString = await getHealthDataAsString();

      // 1. Get temporary directory
      final directory = await getTemporaryDirectory();
      final now = DateTime.now();
      // 파일 이름에 사용할 수 없는 문자를 제거하거나 대체합니다.
      // 예: 콜론(:)은 일반적으로 파일 이름에 사용할 수 없습니다.
      final timestamp =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
      final filePath = '${directory.path}/health_data_$timestamp.txt';

      // 2. Create and write to the file
      final file = File(filePath);
      await file.writeAsString(dataString);
      print("HealthService: 데이터 파일 저장 완료 - $filePath");

      // 3. Share the file
      final shareParams = ShareParams(
        text: 'Sleep Tight 건강 데이터',
        files: [XFile(filePath)],
      );
      await SharePlus.instance.share(shareParams);
      print("HealthService: 파일 공유 완료.");
    } catch (e) {
      print("HealthService: TXT 파일 내보내기 중 오류 발생: $e");
      // UI에 오류 메시지를 표시하도록 오류를 다시 throw하거나 상태를 관리할 수 있습니다.
    }
  }

  Future<Map<String, dynamic>> fetchDataForWatch() async {
    // TODO: 실제 데이터 반환 로직 구현
    return {};
  }

  Future<bool> writeWaterIntake(double amount, DateTime dateTime) async {
    // TODO: 실제 저장 로직 구현
    return true;
  }

  Future<bool> writeCaffeineIntake(double amount, DateTime dateTime) async {
    // TODO: 실제 저장 로직 구현
    return true;
  }
}
