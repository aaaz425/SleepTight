import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/health/services/health_service.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_start_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_start_response.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/report_id_provider.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/sleep_start_time_provider.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/widgets/alarm_toggle_row.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/widgets/time_slot_picker.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _healthService = HealthService();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    try {
      await Permission.location.request();
      await Permission.microphone.request();
      await _healthService.ensureConfigured();
      await Permission.activityRecognition.request();
    } catch (e) {
      print("⚠️ 권한 요청 중 오류 발생: $e");
    }
  }

  Future<SleepStartResponse> startSleep(
    WidgetRef ref,
    DateTime sleepStartTime,
  ) async {
    final dio = ref.read(dioClientProvider);
    final response = await dio.post(
      AppConfig.api.sleep.startSleep,
      data: SleepStartRequest(sleepStartTime: sleepStartTime).toJson(),
    );

    return SleepStartResponse.fromJson(response);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.timer_outlined, size: 28),
            SizedBox(width: 4),
            Text(
              '알람 시간을 설정해보세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),

        const SizedBox(height: 40),

        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: TimeSlotPicker(),
          ),
        ),

        const SizedBox(height: 4),

        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: AlarmToggleRow(),
          ),
        ),

        const SizedBox(height: 60),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 156),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () async {
                final now = DateTime.now();
                final timestamp = now;
                ref.read(sleepStartTimeProvider.notifier).state = timestamp;

                final response = await startSleep(ref, timestamp);

                if (!context.mounted) return;

                ref
                    .read(reportIdNotifierProvider.notifier)
                    .set(response.reportId);
                final currentId = ref.read(reportIdNotifierProvider);
                print('📌 현재 reportIdProvider 상태: $currentId');

                context.go(AppConfig.routes.homeSleeping);
              },
              child: const Text(
                '수면 시작',
                style: TextStyle(fontSize: 16, color: AppColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
