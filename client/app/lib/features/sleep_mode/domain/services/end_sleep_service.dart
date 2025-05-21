import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/network/dio_provider.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/requests/sleep_end_request.dart';
import 'package:sleep_tight/features/sleep_mode/data/models/responses/sleep_end_response.dart';
import 'package:sleep_tight/features/sleep_mode/domain/services/activity_data_service.dart';
import 'package:sleep_tight/features/sleep_mode/domain/services/sleep_stage_service.dart';
import 'package:sleep_tight/main.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter/material.dart';

Future<void> endSleepAndNavigate({
  required BuildContext context,
  required WidgetRef ref,
  required int reportId,
  required DateTime startTime,
  required DateTime endTime,
}) async {
  final stages = await getSleepStages(startDate: startTime, endDate: endTime);
  final dio = ref.read(dioClientProvider);

  try {
    final response = await dio.post(
      AppConfig.api.sleep.endSleep,
      data:
          SleepEndRequest(
            reportId: reportId,
            sleepEndTime: endTime,
            stages: stages,
          ).toJson(),
    );

    final parsed = SleepEndResponse.fromJson(response);

    if (parsed.isValidReport) {
      final activityStart = endTime.subtract(Duration(hours: 24));
      final activityData = await getActivityData(activityStart, endTime);

      await dio.post(
        AppConfig.api.sleep.activityData,
        data: {
          'startTime': activityStart.toUtc().toIso8601String(),
          'endTime': endTime.toUtc().toIso8601String(),
          'records': activityData,
        },
      );
      return;
    }
  } catch (e) {
    debugPrint('수면 종료 실패: $e');
  }

  final overlayContext = navigatorKey.currentState?.overlay?.context;
  if (overlayContext != null) {
    toastification.show(
      context: overlayContext,
      type: ToastificationType.warning,
      style: ToastificationStyle.fillColored,
      description: Text('1시간 미만의 수면은 기록되지 않습니다'),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12.0),
      applyBlurEffect: true,
      showIcon: false,
    );
  }

  if (context.mounted) context.go(AppConfig.routes.home);
}
