import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/core/utils/overlay.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_end_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_end_response.dart';
import 'package:sleep_tight/features/sleep_mode/domain/services/activity_data_service.dart';
import 'package:sleep_tight/features/sleep_mode/domain/services/audio_recording_service.dart';
import 'package:sleep_tight/features/sleep_mode/domain/services/sleep_stage_service.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/report_id_provider.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/sleep_start_time_provider.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/screens/wake_up_screen.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/widgets/alarm_time_display.dart';
import 'package:sleep_tight/main.dart'; // navigatorKey 사용 시 필요
import 'package:sleep_tight/shared/widgets/alarm_trigger_watcher.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';
import 'package:toastification/toastification.dart';

class SleepingScreen extends ConsumerStatefulWidget {
  const SleepingScreen({super.key});

  // endSleep 메소드는 동일하게 유지 가능
  Future<SleepEndResponse> endSleep(
    WidgetRef ref,
    int reportId,
    DateTime sleepEndTime,
    stages,
  ) async {
    final dio = ref.read(dioClientProvider);
    final response = await dio.post(
      AppConfig.api.sleep.endSleep,
      data:
          SleepEndRequest(
            reportId: reportId,
            sleepEndTime: sleepEndTime,
            stages: stages,
          ).toJson(),
    );
    return SleepEndResponse.fromJson(response.data); // response.data로 수정
  }

  @override
  ConsumerState<SleepingScreen> createState() => _SleepingScreenState();
}

class _SleepingScreenState extends ConsumerState<SleepingScreen> {
  late DateTime _now;
  late Timer _timer;
  // late Timer _sendTimer; // 삭제: AudioRecordingService 내부에서 처리

  // UI 파형 표시를 위한 RecorderController
  late final RecorderController _uiWaveformController;
  StreamSubscription?
  _amplitudeSubscription; // AudioRecordingService의 진폭 스트림 구독용

  final recorderService = AudioRecordingService(); // 서비스 인스턴스

  @override
  void initState() {
    super.initState();

    // UI 파형용 RecorderController 초기화
    _uiWaveformController =
        RecorderController()
          ..updateFrequency = const Duration(milliseconds: 100); // 필요에 따라 조절

    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        // mounted 확인 추가
        setState(() => _now = DateTime.now());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reportId = ref.read(reportIdNotifierProvider);
      final dioClient = ref.read(dioClientProvider).dio; // dio 인스턴스 직접 전달

      if (reportId != 0) {
        await recorderService.init(dioClient); // 서비스 초기화

        // AudioRecordingService의 진폭 스트림 구독
        _amplitudeSubscription = recorderService.amplitudeStream.listen(
          (amplitudes) {
            if (mounted && amplitudes.isNotEmpty) {
              // audio_waveforms의 RecorderController에 데이터를 주입하는 방식 확인 필요
              // 예시: controller.addAmplitudes(List<double> amps) 또는 controller.addAmplitude(double amp)
              // 현재 audio_waveforms 패키지는 외부 데이터 주입 API가 명확하지 않을 수 있음.
              // 만약 직접 주입이 어렵다면, 이 부분은 다른 파형 라이브러리나 CustomPaint로 대체해야 할 수 있음.
              // 여기서는 addAmplitude가 있다고 가정. (실제 API 확인 필요)
              // _uiWaveformController.addAmplitude(amplitudes.last); // 마지막 값만 사용하거나 평균/최대값 사용
              // 또는 _uiWaveformController.refresh(); // 만약 내부적으로 데이터를 참조한다면
              // audio_waveforms의 RecorderController가 내부적으로 녹음하지 않고 외부 데이터를 받을 수 있는지 확인이 중요!
              // 현재 audio_waveforms v1.x.x는 외부 데이터 주입 API가 명시적이지 않음.
              // 이 부분은 audio_waveforms 라이브러리의 한계일 수 있습니다.
              // 임시로, 파형 표시는 이전처럼 _uiWaveformController.record()를 사용하고,
              // AudioRecordingService는 별도로 녹음/업로드만 담당하게 둘 수도 있습니다. (최적은 아니지만)
              // 여기서는 이상적인 경우(외부 데이터 주입 가능)를 가정하고 코드를 작성합니다.
              // 실제로는 _uiWaveformController.record()를 호출해야 할 수도 있습니다.
              // debugPrint('Amplitude received for UI: ${amplitudes.length}');
            }
          },
          onError: (e) {
            debugPrint('진폭 스트림 에러: $e');
          },
        );

        // 메인 녹음 세션 시작
        await recorderService.startRecordingSession(reportId.toString());
        debugPrint('SleepingScreen: AudioRecordingService 세션 시작 요청됨.');

        // 기존 _sendTimer 삭제
      } else {
        debugPrint('Report ID가 0이므로 녹음 서비스를 시작하지 않습니다.');
      }
    });
    // 임시: audio_waveforms가 자체 녹음을 해야 한다면... (단일 소스 원칙 위배)
    _uiWaveformController
        .record(
          // audio_waveforms가 외부 데이터 주입을 지원하지 않는 경우의 임시 방편
          // path: ..., // 필요시 경로 지정
          // encoder: ..., // 필요시 인코더 지정
          // sampleRate: ...,
        )
        .then((_) {
          debugPrint('UI용 파형 녹음 시작됨 (audio_waveforms 자체 녹음)');
        })
        .catchError((e) {
          debugPrint('UI용 파형 녹음 시작 오류: $e');
        });
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _uiWaveformController.dispose(); // UI 파형 컨트롤러 해제
    _timer.cancel();
    // _sendTimer.cancel(); // 삭제됨

    // AudioRecordingService의 세션 중지 및 리소스 해제
    // dispose는 async일 수 없으므로, Future를 반환하는 메소드를 호출하고 기다리지 않음
    // 서비스가 백그라운드에서 정리되도록 함
    recorderService
        .stopRecordingSession()
        .then((_) {
          debugPrint("Recording session stopped from dispose.");
          recorderService.dispose().then((_) {
            debugPrint("Recorder service disposed from dispose.");
          });
        })
        .catchError((e) {
          debugPrint("Error stopping/disposing service from dispose: $e");
        });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MM월 dd일 EEEE', 'ko_KR').format(_now);
    final formattedTime = DateFormat('a hh:mm', 'ko_KR').format(_now);
    final reportId = ref.watch(reportIdNotifierProvider);

    return AlarmTriggerWatcher(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedDate,
              style: AppTextStyles.titleT3Rg(color: AppColors.font2),
            ),
            const SizedBox(height: 45),
            Text(
              formattedTime.replaceFirst('AM', '오전').replaceFirst('PM', '오후'),
              style: AppTextStyles.headlineH1Rg(color: AppColors.primaryHv2),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '알람',
                  style: AppTextStyles.titleT3Rg(color: AppColors.font2),
                ),
                const SizedBox(width: 10),
                const AlarmTimeDisplay(),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              // 이 Container는 이제 Text를 표시하는 AudioWaveforms 위젯의 배경/여백 등을 설정합니다.
              // color: AppColors.white, // 기존 파형 배경색, 필요에 따라 유지 또는 변경
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 70,
              ), // 기존 여백 유지
              // padding: const EdgeInsets.symmetric(horizontal: 20), // 패딩은 수정된 AudioWaveforms 내부에서 처리 가능
              height: 120, // 기존 높이 유지 또는 텍스트 표시에 맞게 조절
              child: AudioWaveforms(
                // 수정된 AudioWaveforms 위젯 사용
                size: const Size(double.infinity, 120), // 위젯의 전체 크기
                pcmDataStream:
                    recorderService
                        .rawPcmUiStream, // <<< AudioRecordingService로부터 PCM 스트림 전달
                // --- 아래 속성들은 제거되거나 수정된 AudioWaveforms 위젯의 새 속성으로 대체됩니다 ---
                // recorderController: _uiWaveformController, // 제거됨
                // enableGesture: false, // 제거됨
                // waveStyle: const WaveStyle(...), // 제거됨

                // 수정된 AudioWaveforms 위젯에 여전히 유효한 속성들 (필요에 따라 설정)
                backgroundColor: Colors.black87, // 텍스트 표시 영역 배경색 예시
                padding: const EdgeInsets.all(8.0), // 텍스트 주변 패딩 예시
                // margin: ..., // 이미 외부 Container에 margin이 있으므로 중복 주의
                // decoration: ...,
              ),
            ),
            const SizedBox(height: 34),
            CustomButton(
              width: 156,
              height: 48,
              onPressed: () async {
                // 수면 종료 로직 (기존과 거의 동일)
                final now = DateTime.now();
                final startTime = ref.read(sleepStartTimeProvider);
                final endTime = now;

                // 녹음 서비스 중지
                await recorderService.stopRecordingSession();
                debugPrint('수면 종료 버튼 클릭: 녹음 서비스 중지 요청됨.');

                final stages = await getSleepStages(
                  startDate: startTime,
                  endDate: endTime,
                );

                try {
                  final response = await widget.endSleep(
                    ref,
                    reportId,
                    endTime,
                    stages,
                  );

                  if (response.isValidReport) {
                    final activityStart = now.subtract(
                      const Duration(hours: 24),
                    );
                    final activityData = await getActivityData(
                      activityStart,
                      now,
                    );

                    final dio = ref.read(dioClientProvider);
                    await dio.post(
                      AppConfig.api.sleep.activityData,
                      data: {
                        'startTime': activityStart.toUtc().toIso8601String(),
                        'endTime': endTime.toUtc().toIso8601String(),
                        'records': activityData,
                      },
                    );

                    if (!context.mounted) return;
                    showOverlay(context: context, child: const WakeUpScreen());
                    return;
                  }
                } catch (e) {
                  debugPrint('수면 종료 요청 실패: $e');
                  if (e is DioException) {
                    debugPrint('DioException Response: ${e.response}');
                  }
                }

                if (!context.mounted) return;

                final overlayContext =
                    navigatorKey.currentState?.overlay?.context;
                if (overlayContext != null) {
                  toastification.show(
                    context: overlayContext,
                    type: ToastificationType.warning,
                    style: ToastificationStyle.fillColored,
                    description: const Text('1시간 미만의 수면은 기록되지 않습니다'),
                    alignment: Alignment.bottomCenter,
                    autoCloseDuration: const Duration(seconds: 4),
                    borderRadius: BorderRadius.circular(12.0),
                    applyBlurEffect: true,
                    showIcon: false,
                  );
                }

                if (context.mounted) context.go(AppConfig.routes.home);
              },
              text: '수면 종료',
              theme: 'gray',
            ),
          ],
        ),
      ),
    );
  }
}
