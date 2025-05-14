import 'dart:async';

import 'package:app/core/config/app_config.dart';
import 'package:app/core/config/theme/color.dart';
import 'package:app/core/network/dio_provider.dart';
import 'package:app/core/utils/overlay.dart';
import 'package:app/features/sleep_mode/data/models/requests/sleep_end_request.dart';
import 'package:app/features/sleep_mode/domain/services/audio_recording_service.dart';
import 'package:app/features/sleep_mode/domain/services/sleep_stage_service.dart';
import 'package:app/features/sleep_mode/presentation/provider/report_id_provider.dart';
import 'package:app/features/sleep_mode/presentation/provider/sleep_mode_view_model_provider.dart';
import 'package:app/features/sleep_mode/presentation/provider/sleep_start_time_provider.dart';
import 'package:app/features/sleep_mode/presentation/screens/wake_up_screen.dart';
import 'package:app/features/sleep_mode/presentation/widgets/alarm_time_display.dart';
import 'package:app/shared/widgets/alarm_trigger_watcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SleepingScreen extends ConsumerStatefulWidget {
  const SleepingScreen({super.key});

  @override
  ConsumerState<SleepingScreen> createState() => _SleepingScreenState();
}

class _SleepingScreenState extends ConsumerState<SleepingScreen> {
  late DateTime _now;
  late Timer _timer;
  late Timer _sendTimer;

  final _recorder = FlutterSoundRecorder();

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });

    final dioClient = ref.read(dioClientProvider); // DioClient를 가져옴
    final reportId = ref.read(reportIdNotifierProvider);
    final audioRecordingService = AudioRecordingService(
      _recorder,
      dioClient.dio,
    );

    // 오디오 녹음 및 전송 시작 (예: 10초마다)
    if (reportId != 0) {
      _sendTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        print('10초 지남');
        audioRecordingService.recordAndSendAudio(reportId.toString());
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _sendTimer.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'MM월 dd일 EEEE',
      'ko_KR',
    ).format(_now);
    final String formattedTime = DateFormat('a hh:mm', 'ko_KR').format(_now);

    return AlarmTriggerWatcher(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 84, bottom: 114),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 16, color: AppColors.font2),
              ),

              SizedBox(height: 45),

              Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 32,
                  color: AppColors.primaryHv2,
                ),
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '알람',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.font2,
                    ),
                  ),

                  SizedBox(width: 10),

                  AlarmTimeDisplay(),
                ],
              ),

              SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(gradient: AppColors.linearGradient3),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 104,
                    bottom: 104,
                    left: 20,
                    right: 20,
                  ),
                  child: Center(
                    // Todo: 파형 그래프 수정
                    child: Image.asset(
                      'assets/images/sound_wave.png',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 34),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 156),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bgRegular,
                      foregroundColor: AppColors.primaryHv,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () async {
                      // Todo: 수면 종료
                      final viewModel = ref.read(
                        sleepModeViewModelProvider.notifier,
                      );

                      final now = DateTime.now();
                      final startTime = ref.watch(sleepStartTimeProvider);
                      final endTime = now.toIso8601String();
                      final reportId = ref.read(reportIdNotifierProvider);

                      final sleepStages = await getSleepStages(
                        startDate: startTime,
                        endDate: endTime,
                      );

                      final request = SleepEndRequest(
                        reportId: reportId,
                        sleepEndTime: endTime,
                        stages: sleepStages,
                      );

                      final success = await viewModel.endSleep(request);

                      if (!context.mounted) return;

                      if (success) {
                        context.go(AppConfig.routes.homeSleeping);
                      }

                      showOverlay(context: context, child: WakeUpScreen());
                    },
                    child: const Text('수면 종료', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
