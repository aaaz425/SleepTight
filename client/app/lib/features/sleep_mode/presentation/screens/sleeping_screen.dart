import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
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
import 'package:sleep_tight/main.dart';
import 'package:sleep_tight/shared/widgets/alarm_trigger_watcher.dart';
import 'package:toastification/toastification.dart';

class SleepingScreen extends ConsumerStatefulWidget {
  const SleepingScreen({super.key});

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

    return SleepEndResponse.fromJson(response);
  }

  @override
  ConsumerState<SleepingScreen> createState() => _SleepingScreenState();
}

class _SleepingScreenState extends ConsumerState<SleepingScreen> {
  late DateTime _now;
  late Timer _timer;
  late Timer _sendTimer;
  late final RecorderController _waveformRecorder;

  final recorderService = AudioRecordingService();

  @override
  void initState() {
    super.initState();
    _waveformRecorder =
        RecorderController()
          ..updateFrequency = const Duration(milliseconds: 30);

    // 시각화용 녹음 시작
    _waveformRecorder
        .record()
        .then((_) => print('시각화용 녹음 시작됨'))
        .catchError((e) => print('시각화 녹음 오류: $e'));

    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reportId = ref.read(reportIdNotifierProvider);
      final dioClient = ref.read(dioClientProvider).dio;

      if (reportId != 0) {
        final recorderService = AudioRecordingService();
        await recorderService.init(dioClient); // 최초 1회만
        _sendTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          recorderService.enqueueRecord(reportId.toString());
        });
      }
    });
  }

  @override
  void dispose() {
    _waveformRecorder.dispose();
    _timer.cancel();
    _sendTimer.cancel();
    recorderService.dispose();
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
              style: const TextStyle(fontSize: 16, color: AppColors.font2),
            ),
            const SizedBox(height: 45),
            Text(
              formattedTime.replaceFirst('AM', '오전').replaceFirst('PM', '오후'),
              style: const TextStyle(fontSize: 32, color: AppColors.primaryHv2),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '알람',
                  style: TextStyle(fontSize: 16, color: AppColors.font2),
                ),
                const SizedBox(width: 10),
                const AlarmTimeDisplay(),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 120,
              child: AudioWaveforms(
                recorderController: _waveformRecorder,
                enableGesture: false,
                size: Size(double.infinity, 120),
                waveStyle: WaveStyle(
                  showMiddleLine: false,
                  waveColor: Color(0xFF3A6EFF),
                  extendWaveform: true,
                  spacing: 2.5,
                  waveThickness: 2,
                  scaleFactor: 50.0,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF000000),
                      Color(0xFF3A6EFF),
                      Color(0xFF000000),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(Rect.fromLTWH(0, 0, 400, 120)),
                ),
              ),
            ),

            const SizedBox(height: 34),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 156),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bgRegular,
                    foregroundColor: AppColors.primaryHv,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () async {
                    final now = DateTime.now();
                    final startTime = ref.read(sleepStartTimeProvider);
                    final endTime = now;

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
                            'startTime': activityStart.toIso8601String(),
                            'endTime': endTime.toIso8601String(),
                            'records': activityData,
                          },
                        );

                        if (!context.mounted) return;
                        showOverlay(
                          context: context,
                          child: const WakeUpScreen(),
                        );
                        return;
                      }
                    } catch (e) {
                      debugPrint('수면 종료 요청 실패: $e');
                    }

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

                    context.go(AppConfig.routes.home);
                  },
                  child: const Text('수면 종료', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
