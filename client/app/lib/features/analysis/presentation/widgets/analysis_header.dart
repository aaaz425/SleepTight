import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/analysis/presentation/providers/selected_date_provider.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/calendar.dart';

class AnalysisHeader extends ConsumerWidget {
  const AnalysisHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    String weekdayToKorean(int weekday) {
      const days = ['월', '화', '수', '목', '금', '토', '일'];
      return days[(weekday - 1) % 7];
    }

    String getDateRange(DateTime date) {
      final prev = date.subtract(Duration(days: 1));

      if (date.month != prev.month) {
        return '${prev.month}/${prev.day}-${date.month}/${date.day} ${weekdayToKorean(date.weekday)}';
      }

      return '${prev.month}/${prev.day}-${date.day} ${weekdayToKorean(date.weekday)}';
    }

    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              getDateRange(selectedDate),
              style: AppTextStyles.titleT2Sb(color: AppColors.white),
            ),
          ),
          Positioned(
            right: 20,
            child: Builder(
              builder:
                  (context) => GestureDetector(
                    onTap: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: '닫기',
                        barrierColor: Colors.transparent, // 투명으로 두고
                        pageBuilder:
                            (_, __, ___) => const CustomCalendarDialog(),
                        transitionBuilder: (_, animation, __, child) {
                          return Stack(
                            children: [
                              // 배경 블러 + 딤 + 클릭 감지
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop(); // 배경 클릭 시 다이얼로그 닫기
                                },
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 4,
                                    sigmaY: 4,
                                  ),
                                  child: Container(
                                    color: const Color(0xB3000000),
                                  ),
                                ),
                              ),
                              FadeTransition(opacity: animation, child: child),
                            ],
                          );
                        },
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/icons/calendar.svg',
                      width: 28,
                      height: 28,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
