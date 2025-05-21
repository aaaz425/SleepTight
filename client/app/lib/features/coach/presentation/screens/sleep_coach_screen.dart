import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/coach/data/models/sleep_coach_model.dart';
import 'package:sleep_tight/features/coach/data/services/sleep_coach_service.dart';
import 'package:sleep_tight/features/coach/presentation/widgets/coach_card.dart';
import 'package:sleep_tight/features/sleep_mode/domain/services/activity_data_service.dart';

class SleepCoachingScreen extends ConsumerWidget {
  const SleepCoachingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: AppBar(
          title: Text(
            '수면 코칭',
            style: AppTextStyles.headlineH3Sb(color: AppColors.white),
          ),
          scrolledUnderElevation: 0,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: FutureBuilder<List<SleepCoachModel>>(
        future: _loadCoaching(ref, today, now),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.font3),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '문제가 발생했어요: ${snapshot.error}',
                style: AppTextStyles.bodyB1Rg(color: AppColors.accessibleRed),
              ),
            );
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Center(
              child: Text(
                '아직 오늘의 수면 코칭 데이터가 없어요.',
                style: AppTextStyles.bodyB1Rg(color: AppColors.white),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI가 분석한 오늘의 수면 코칭',
                  style: AppTextStyles.bodyB2Rg(color: AppColors.white),
                ),
                SizedBox(height: 8),
                ...data.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CoachingCard(item: item),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<List<SleepCoachModel>> _loadCoaching(
    WidgetRef ref,
    DateTime start,
    DateTime end,
  ) async {
    final activityData = await getActivityData(start, end);
    return fetchSleepCoach(ref, end, activityData);
  }
}
