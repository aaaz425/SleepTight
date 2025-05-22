import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/analysis/data/services/sleep_report_calendar_service.dart';
import 'package:sleep_tight/features/analysis/presentation/providers/selected_date_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendarDialog extends ConsumerStatefulWidget {
  const CustomCalendarDialog({super.key});

  @override
  ConsumerState<CustomCalendarDialog> createState() =>
      _CustomCalendarDialogState();
}

class _CustomCalendarDialogState extends ConsumerState<CustomCalendarDialog> {
  late DateTime focusedDay;
  late DateTime selectedDay;
  late Future<List<DateTime>> _sleepDatesFuture;
  List<DateTime> _sleepDates = [];

  @override
  void initState() {
    super.initState();

    final initDate = ref.read(selectedDateProvider);
    focusedDay = initDate;
    selectedDay = initDate;
    _sleepDatesFuture = fetchSleepDates(ref, initDate);
    _sleepDatesFuture.then((dates) {
      setState(() {
        _sleepDates = dates;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Todo: 일지 있는 날 표시
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: AppColors.gray01,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 22,
              right: 22,
              bottom: 8,
            ),
            child: TableCalendar(
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final hasReport = _sleepDates.any((d) => isSameDay(d, day));
                  if (!hasReport) return null;

                  return Positioned(
                    bottom: 10,
                    child: Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.accessibleGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              locale: 'ko_KR',
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, selectedDay),
              enabledDayPredicate: (day) {
                DateTime now = DateTime.now();
                DateTime todayDateOnly = DateTime(now.year, now.month, now.day);

                final dateOnly = DateTime(day.year, day.month, day.day);
                return !dateOnly.isAfter(todayDateOnly);
              },
              onDaySelected: (day, focus) {
                setState(() {
                  selectedDay = day;
                  focusedDay = focus;
                });
              },
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: AppColors.font2, fontSize: 13),
                weekendStyle: TextStyle(
                  color: AppColors.accessibleRed,
                  fontSize: 13,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTextStyles.titleT3Rg(color: AppColors.white),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: AppTextStyles.titleT3Rg(
                  color: AppColors.white,
                ),
                weekendTextStyle: AppTextStyles.titleT3Rg(
                  color: AppColors.white,
                ),
                // todayTextStyle: AppTextStyles.headlineH3Sb(
                //   color: AppColors.primaryHv,
                // ),
                todayTextStyle: TextStyle(
                  fontWeight: FontWeight.w600, // semibold
                  fontSize: 18,
                  height: 1.4, // 140%
                  letterSpacing: -0.45,
                  color: AppColors.primaryHv,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0x103A6EFF),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: AppTextStyles.headlineH3Sb(
                  color: AppColors.primaryHv,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.gray05, width: 0.25),
              ),
            ),
            child: IntrinsicHeight(
              // 자식들의 높이를 맞춰줌
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                      child: Text(
                        '닫기',
                        style: AppTextStyles.button3Md(color: AppColors.white),
                      ),
                    ),
                  ),
                  VerticalDivider(thickness: 0.25, color: AppColors.gray05),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        ref
                            .read(selectedDateProvider.notifier)
                            .update(selectedDay);
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text(
                        '확인',
                        style: AppTextStyles.button3Md(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
