// lib/features/health/services/health_service.dart
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math'; // min, max 사용

// 수정된 모델 및 enum 헬퍼 함수 임포트
import '../models/sleep_model.dart';

class HealthService {
  final Health _health = Health();

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
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.FLIGHTS_CLIMBED, // 오른 층계
    HealthDataType.WATER, // 수분 섭취량
    HealthDataType.WORKOUT, // 운동 기록
    HealthDataType.LEAN_BODY_MASS, // 제지방량
  ];

  // 수면 데이터 타입 정의 (실제 Health Connect에서 제공하는 상세 단계)
  static final _sleepDataTypes = [
    HealthDataType.SLEEP_ASLEEP, // 총 수면 시간 (단계 구분 없는 수면)
    HealthDataType.SLEEP_AWAKE, // 수면 중 깨어있는 시간
    HealthDataType.SLEEP_DEEP, // 깊은 수면
    HealthDataType.SLEEP_LIGHT, // 얕은 수면
    HealthDataType.SLEEP_REM, // REM 수면
    // HealthDataType.SLEEP_IN_BED, // 침대에 머문 시간 (필요하다면 포함)
  ];

  // 서버 엔드포인트 URL (실제 URL로 교체 필요)
  final String _serverBaseUrl =
      "YOUR_SERVER_ENDPOINT_HERE"; // << 중요: 실제 서버 URL로 변경하세요!

  /// 요청된 건강 데이터 타입에 대한 권한을 사용자에게 요청합니다.
  Future<bool> _requestPermissions(List<HealthDataType> types) async {
    // 읽기 전용 권한으로 요청
    bool? requested = await _health.requestAuthorization(
      types,
      permissions: [
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        // _sleepDataTypes에 해당하는 READ 권한도 명시적으로 추가
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
      ],
    );
    print("권한 요청 결과: $requested");
    return requested ?? false;
  }

  /// 요청된 건강 데이터 타입에 대한 현재 권한 상태를 확인합니다.
  Future<bool> _checkPermissions(List<HealthDataType> types) async {
    bool? hasPermissions = await _health.hasPermissions(types);
    return hasPermissions ?? false;
  }

  /// 지정된 기간 동안의 활동 데이터를 Health Connect로부터 가져옵니다.
  Future<List<HealthDataPoint>> _fetchActivityData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    List<HealthDataPoint> activityData = [];
    bool permissionsGranted = await _checkPermissions(_activityTypes);
    if (!permissionsGranted) {
      permissionsGranted = await _requestPermissions(_activityTypes);
    }

    if (permissionsGranted) {
      try {
        activityData = await _health.getHealthDataFromTypes(
          startDate,
          endDate,
          _activityTypes,
        );
        activityData = HealthFactory.removeDuplicates(
          activityData,
        ); // 중복 데이터 제거
      } catch (e) {
        print("활동 데이터 가져오기 오류: $e");
        if (e.toString().contains("HealthConnectNotAvailableException")) {
          print("Health Connect 앱이 설치되어 있지 않거나 사용할 수 없습니다.");
          // 사용자에게 알림을 표시하는 로직 추가 가능
        }
      }
    } else {
      print("활동 데이터에 대한 권한이 부여되지 않았습니다.");
    }
    return activityData;
  }

  /// 가져온 활동 데이터를 서버로 전송합니다.
  Future<void> _sendActivityDataToServer(
    String path,
    List<HealthDataPoint> dataPoints,
  ) async {
    if (dataPoints.isEmpty) {
      print("$path (Activity): 전송할 데이터가 없습니다.");
      return;
    }
    // HealthDataPoint를 서버가 이해할 수 있는 JSON 형태로 변환
    List<Map<String, dynamic>> jsonData =
        dataPoints.map((point) {
          dynamic value;
          if (point.value is NumericHealthValue) {
            value = (point.value as NumericHealthValue).numericValue.toDouble();
          } else if (point.value is AudiogramHealthValue) {
            // AudiogramHealthValue 처리 (필요한 경우)
            value =
                (point.value as AudiogramHealthValue)
                    .frequenciesAndThresholdsMap;
          } else if (point.value is WorkoutHealthValue) {
            // WorkoutHealthValue 처리 (필요한 경우)
            value = {
              'totalEnergyBurned':
                  (point.value as WorkoutHealthValue).totalEnergyBurned,
              'totalDistance':
                  (point.value as WorkoutHealthValue).totalDistance,
              'workoutType':
                  (point.value as WorkoutHealthValue).workoutActivityType.name,
            };
          } else {
            value = point.value.toString(); // 기타 타입은 문자열로
          }

          return {
            'value': value,
            'unit': point.unitString,
            'date_from': point.dateFrom.toIso8601String(),
            'date_to': point.dateTo.toIso8601String(),
            'data_type': point.typeString,
            'platform': point.platform.name,
            'source_name': point.sourceName,
            'source_device_id': point.sourceDeviceId,
            'source_id': point.sourceId,
          };
        }).toList();

    try {
      final response = await http.post(
        Uri.parse('$_serverBaseUrl/$path'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "data": jsonData,
        }), // 서버가 "data" 키 아래 리스트를 기대한다고 가정
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("$path (Activity): 데이터가 성공적으로 서버에 전송되었습니다.");
      } else {
        print(
          "$path (Activity): 서버 전송 실패. 상태 코드: ${response.statusCode}, 응답: ${response.body}",
        );
      }
    } catch (e) {
      print("$path (Activity): 서버 전송 중 예외 발생: $e");
    }
  }

  /// 지정된 기간 동안의 수면 데이터를 Health Connect로부터 가져와 SleepSessionData 모델로 처리합니다.
  Future<List<SleepSessionData>> _fetchAndProcessSleepData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    List<SleepSessionData> processedSessions = [];
    bool permissionsGranted = await _checkPermissions(_sleepDataTypes);
    if (!permissionsGranted) {
      permissionsGranted = await _requestPermissions(_sleepDataTypes);
    }

    if (permissionsGranted) {
      try {
        List<HealthDataPoint> rawSleepData = await _health
            .getHealthDataFromTypes(startDate, endDate, _sleepDataTypes);
        rawSleepData = HealthFactory.removeDuplicates(rawSleepData);

        if (rawSleepData.isEmpty) {
          print("지정된 기간에 수면 데이터가 없습니다.");
          return processedSessions;
        }

        // 날짜별로 HealthDataPoint 그룹화 (세션의 종료일을 기준으로 그룹화)
        Map<DateTime, List<HealthDataPoint>> dailyRawData = {};
        for (var point in rawSleepData) {
          DateTime dateKey = DateTime(
            point.dateTo.year,
            point.dateTo.month,
            point.dateTo.day,
          );
          dailyRawData.putIfAbsent(dateKey, () => []).add(point);
        }

        // 각 날짜 그룹을 하나의 SleepSessionData로 처리
        for (var entry in dailyRawData.entries) {
          DateTime sessionDateKey = entry.key;
          List<HealthDataPoint> pointsForDay = entry.value;

          if (pointsForDay.isEmpty) continue;

          // 세션 전체 시작/종료 시간 계산
          DateTime sessionOverallStartTime = pointsForDay
              .map((p) => p.dateFrom)
              .reduce((a, b) => a.isBefore(b) ? a : b);
          DateTime sessionOverallEndTime = pointsForDay
              .map((p) => p.dateTo)
              .reduce((a, b) => a.isAfter(b) ? a : b);

          Map<HealthDataType, double> summaryMinutes = {
            HealthDataType.SLEEP_ASLEEP: 0,
            HealthDataType.SLEEP_AWAKE: 0,
            HealthDataType.SLEEP_DEEP: 0,
            HealthDataType.SLEEP_LIGHT: 0,
            HealthDataType.SLEEP_REM: 0,
          };
          List<SleepSegment> segments = [];

          for (var point in pointsForDay) {
            if (point.value is! NumericHealthValue) {
              print(
                "경고: ${point.type.name} 데이터의 값이 NumericHealthValue가 아닙니다. 값: ${point.value}. 이 데이터는 건너뜁니다.",
              );
              continue;
            }
            // Health Connect 수면 데이터는 분(MINUTES) 단위로 제공됨
            if (point.unit != HealthDataUnit.MINUTES) {
              print(
                "경고: ${point.type.name} 데이터의 단위가 MINUTES가 아닙니다 (${point.unitString}). 값: ${point.value}. 이 데이터는 건너뜁니다.",
              );
              continue;
            }
            double duration =
                (point.value as NumericHealthValue).numericValue.toDouble();

            // 요약 데이터 집계
            if (summaryMinutes.containsKey(point.type)) {
              summaryMinutes[point.type] =
                  summaryMinutes[point.type]! + duration;
            }

            // 시계열 세그먼트 생성
            segments.add(
              SleepSegment(
                startTime: point.dateFrom,
                endTime: point.dateTo,
                stage: healthDataTypeToSleepStage(
                  point.type.name,
                ), // String to Enum
                durationInMinutes: duration,
              ),
            );
          }

          segments.sort((a, b) => a.startTime.compareTo(b.startTime)); // 시간순 정렬

          processedSessions.add(
            SleepSessionData(
              sessionStartTime: sessionOverallStartTime,
              sessionEndTime: sessionOverallEndTime,
              date: sessionDateKey,
              totalSleepMinutes: summaryMinutes[HealthDataType.SLEEP_ASLEEP]!,
              awakeMinutesInSleep: summaryMinutes[HealthDataType.SLEEP_AWAKE]!,
              deepSleepMinutes: summaryMinutes[HealthDataType.SLEEP_DEEP]!,
              lightSleepMinutes: summaryMinutes[HealthDataType.SLEEP_LIGHT]!,
              remSleepMinutes: summaryMinutes[HealthDataType.SLEEP_REM]!,
              segments: segments,
            ),
          );
        }
      } catch (e, stacktrace) {
        print("수면 데이터 가져오기 또는 처리 중 오류 발생: $e");
        print("Stacktrace: $stacktrace");
        if (e.toString().contains("HealthConnectNotAvailableException")) {
          print("Health Connect 앱이 설치되어 있지 않거나 사용할 수 없습니다.");
        }
      }
    } else {
      print("수면 데이터에 대한 권한이 부여되지 않았습니다.");
    }
    processedSessions.sort((a, b) => a.date.compareTo(b.date)); // 날짜순 정렬
    return processedSessions;
  }

  /// 처리된 수면 데이터(SleepSessionData 리스트)를 서버로 전송합니다.
  Future<void> _sendSleepDataToServer(
    String path,
    List<SleepSessionData> sessions,
  ) async {
    if (sessions.isEmpty) {
      print("$path (Sleep): 전송할 데이터가 없습니다.");
      return;
    }
    List<Map<String, dynamic>> jsonData =
        sessions.map((session) => session.toJson()).toList();

    try {
      final response = await http.post(
        Uri.parse('$_serverBaseUrl/$path'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData), // 서버가 JSON 배열을 직접 받는다고 가정
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("$path (Sleep): 데이터가 성공적으로 서버에 전송되었습니다.");
      } else {
        print(
          "$path (Sleep): 서버 전송 실패. 상태 코드: ${response.statusCode}, 응답 본문: ${response.body}",
        );
      }
    } catch (e) {
      print("$path (Sleep): 서버 전송 중 예외 발생: $e");
    }
  }

  /// 앱 초기 실행 시 과거 데이터(예: 30일치)를 동기화합니다.
  Future<void> performInitialDataSync() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool initialSyncDone = prefs.getBool('initialHealthSyncDone') ?? false;

    // 테스트를 위해 강제로 초기 동기화를 실행하려면 아래 주석을 해제하세요.
    // initialSyncDone = false;

    if (initialSyncDone) {
      print("초기 데이터 동기화는 이미 완료되었습니다.");
      return;
    }
    print("초기 데이터 동기화 시작 (최근 30일)...");

    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(const Duration(days: 30));

    List<HealthDataType> allRequiredTypes = [
      ..._activityTypes,
      ..._sleepDataTypes,
    ];
    // 초기 동기화 시에는 모든 필요한 권한을 한 번에 요청합니다.
    bool permissionsGranted = await _requestPermissions(allRequiredTypes);

    if (!permissionsGranted) {
      print("초기 동기화 실패: 모든 필수 데이터에 대한 권한이 부여되지 않았습니다.");
      // 사용자에게 권한 설정 화면으로 안내하거나, 앱 기능 제한 등을 고려할 수 있습니다.
      return;
    }

    // 활동 데이터 동기화
    print("초기 활동 데이터 가져오는 중...");
    List<HealthDataPoint> activityData = await _fetchActivityData(
      startDate,
      endDate,
    );
    print("초기 활동 데이터 ${activityData.length}건 가져옴. 서버로 전송 시도...");
    await _sendActivityDataToServer("sync/initial/activity", activityData);

    // 수면 데이터 동기화
    print("초기 수면 데이터 가져오는 중...");
    List<SleepSessionData> sleepSessions = await _fetchAndProcessSleepData(
      startDate,
      endDate,
    );
    print("초기 수면 데이터 ${sleepSessions.length} 세션 가져옴. 서버로 전송 시도...");
    await _sendSleepDataToServer("sync/initial/sleep", sleepSessions);

    // 모든 과정이 (적어도 시도) 완료되면 플래그 설정
    // 실제로는 서버 응답 성공 여부까지 확인 후 플래그를 설정하는 것이 더 견고합니다.
    if (permissionsGranted) {
      // 최소한 권한은 얻었어야 함
      await prefs.setBool('initialHealthSyncDone', true);
      print("초기 데이터 동기화 시도 완료 및 플래그 설정.");
    } else {
      print("초기 데이터 동기화 중 권한 문제가 있어 플래그를 설정하지 않습니다.");
    }
  }

  /// 최근 데이터(예: 7일치 또는 마지막 동기화 이후)를 동기화합니다.
  /// 이 함수는 앱이 백그라운드에서 포어그라운드로 전환될 때 호출될 수 있습니다.
  Future<void> syncRecentData() async {
    print("최근 건강 데이터 동기화 시작 (최근 7일)...");
    DateTime endDate = DateTime.now();
    // 마지막 동기화 시간을 기준으로 startDate를 설정하는 것이 이상적입니다.
    // 여기서는 예시로 최근 7일 데이터를 가져옵니다.
    DateTime startDate = endDate.subtract(const Duration(days: 7));

    // 활동 데이터 동기화
    bool activityPermissions = await _checkPermissions(_activityTypes);
    if (!activityPermissions) {
      activityPermissions = await _requestPermissions(_activityTypes);
    }

    if (activityPermissions) {
      print("최근 활동 데이터 가져오는 중...");
      List<HealthDataPoint> activityData = await _fetchActivityData(
        startDate,
        endDate,
      );
      print("최근 활동 데이터 ${activityData.length}건 가져옴. 서버로 전송 시도...");
      await _sendActivityDataToServer("sync/recent/activity", activityData);
    } else {
      print("최근 활동 데이터 동기화 건너뜀: 권한 없음.");
    }

    // 수면 데이터 동기화
    bool sleepPermissions = await _checkPermissions(_sleepDataTypes);
    if (!sleepPermissions) {
      sleepPermissions = await _requestPermissions(_sleepDataTypes);
    }

    if (sleepPermissions) {
      print("최근 수면 데이터 가져오는 중...");
      List<SleepSessionData> sleepSessions = await _fetchAndProcessSleepData(
        startDate,
        endDate,
      );
      print("최근 수면 데이터 ${sleepSessions.length} 세션 가져옴. 서버로 전송 시도...");
      // 서버에서는 이 데이터를 기존 데이터와 비교하여 업데이트하거나 새로 추가하는 로직이 필요합니다.
      await _sendSleepDataToServer("sync/recent/sleep", sleepSessions);
    } else {
      print("최근 수면 데이터 동기화 건너뜀: 권한 없음.");
    }

    print("최근 건강 데이터 동기화 시도 완료.");
  }
}
