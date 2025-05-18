import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/analysis/presentation/providers/selected_date_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class WeekDateSelector extends ConsumerWidget {
  const WeekDateSelector({super.key});

  static const List<String> weekDayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  List<DateTime> _getWeekDates(DateTime date) {
    final int weekday = date.weekday;
    final monday = date.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Todo: 일지 있는 날 표시
    final selectedDate = ref.watch(selectedDateProvider);
    final weekDates = _getWeekDates(selectedDate);

    return Container(
      height: 80,
      color: AppColors.gray02,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Row(
          children:
              weekDates.map((date) {
                final isSelected = isSameDay(date, selectedDate);
                final isSaturday = date.weekday == DateTime.saturday;
                final isSunday = date.weekday == DateTime.sunday;
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final targetDate = DateTime(date.year, date.month, date.day);
                final isFuture = targetDate.isAfter(today);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final targetDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                      );

                      if (!targetDate.isAfter(today)) {
                        ref.read(selectedDateProvider.notifier).update(date);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.gray03 : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weekDayLabels[date.weekday - 1],
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  (isSunday
                                      ? AppColors.accessibleRed
                                      : isSaturday
                                      ? AppColors.accessibleBlue
                                      : isSelected
                                      ? Colors.white
                                      : AppColors.font2),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  isFuture
                                      ? AppColors.font3
                                      : isSunday
                                      ? AppColors.accessibleRed
                                      : isSaturday
                                      ? AppColors.accessibleBlue
                                      : AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
