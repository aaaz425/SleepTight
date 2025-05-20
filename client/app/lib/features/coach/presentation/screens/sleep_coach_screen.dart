// SleepCoachingScreen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/features/coach/presentation/provider/sleep_coach.dart';
import 'package:sleep_tight/features/coach/presentation/widgets/coach_card.dart';
import 'package:intl/intl.dart';

class SleepCoachingScreen extends ConsumerWidget {
  const SleepCoachingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final formatted = DateFormat('yyyy-MM-dd').format(now); // → '2025-05-19'

    final coachingAsync = ref.watch(sleepCoachingProvider(formatted));

    return Scaffold(
      body: coachingAsync.when(
        data:
            (data) => ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return CoachingCard(item: item);
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('문제가 발생했어요: $e')),
      ),
    );
  }
}
