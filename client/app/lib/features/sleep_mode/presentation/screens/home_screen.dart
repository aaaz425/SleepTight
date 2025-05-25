import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/health/services/health_service.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_start_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_start_response.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/report_id_provider.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/sleep_start_time_provider.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/widgets/alarm_toggle_row.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/widgets/time_slot_picker.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';

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
      await Permission.activityRecognition.request();
      await _healthService.requestHealthPermissions();
    } catch (e) {
      debugPrint("⚠️ 권한 요청 중 오류 발생: $e");
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
          children: [
            SvgPicture.asset(
              'assets/icons/alarm.svg',
              width: 28,
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
            ),
            SizedBox(width: 4),
            Text(
              '알람 시간을 설정해보세요',
              style: AppTextStyles.titleT3Sb(color: AppColors.white),
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

        const SizedBox(height: 80),

        CustomButton(
          width: 156,
          height: 48,
          onPressed: () async {
            final now = DateTime.now();
            final timestamp = now;
            ref.read(sleepStartTimeProvider.notifier).state = timestamp;

            final response = await startSleep(ref, timestamp);

            if (!context.mounted) return;

            ref.read(reportIdNotifierProvider.notifier).set(response.reportId);
            final currentId = ref.read(reportIdNotifierProvider);
            debugPrint('📌 현재 reportIdProvider 상태: $currentId');

            context.go(AppConfig.routes.homeSleeping);
          },
          text: '수면 시작',
          textStyle: AppTextStyles.button1Sb(color: AppColors.white),
          textColor: AppColors.white,
        ),
      ],
    );
  }
}
