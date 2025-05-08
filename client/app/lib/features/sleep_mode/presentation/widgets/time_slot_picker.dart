import 'package:app/core/config/theme/color.dart';
import 'package:app/features/sleep_mode/presentation/provider/alarm_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeSlotPicker extends ConsumerStatefulWidget {
  const TimeSlotPicker({super.key});

  @override
  ConsumerState<TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends ConsumerState<TimeSlotPicker> {
  late String _amPm;
  late int _hour;
  late int _minute;

  final List<String> _amPmOptions = ['오전', '오후'];
  final List<int> _hours = List.generate(12, (index) => index + 1);
  final List<int> _minutes = List.generate(60, (index) => index);

  final FixedExtentScrollController _hourController =
      FixedExtentScrollController();
  final FixedExtentScrollController _minuteController =
      FixedExtentScrollController();
  final FixedExtentScrollController _amPmController =
      FixedExtentScrollController();

  bool _initialized = false;

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _amPmController.dispose();
    super.dispose();
  }

  void _updateAlarm() {
    final alarm = ref
        .read(alarmTimeProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);

    if (alarm == null) return;

    final updated = alarm.copyWith(amPm: _amPm, hour: _hour, minute: _minute);

    ref.read(updateAlarmTimeProvider(updated).future);
  }

  @override
  Widget build(BuildContext context) {
    final alarmAsync = ref.watch(alarmTimeProvider);

    return alarmAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, _) => const SizedBox.shrink(),
      data: (alarm) {
        if (!_initialized) {
          _amPm = alarm.amPm;
          _hour = alarm.hour;
          _minute = alarm.minute;
          _initialized = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _amPmController.jumpToItem(_amPm == '오전' ? 0 : 1);
            _hourController.jumpToItem(_hour - 1);
            _minuteController.jumpToItem(_minute);
          });
        }

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(gradient: AppColors.linearGradient3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TimeSlot(
                    options: _amPmOptions,
                    controller: _amPmController,
                    onChanged: (value) {
                      setState(() {
                        _amPm = value;
                      });
                      _updateAlarm();
                    },
                    highlightIndex: _amPm == '오전' ? 0 : 1,
                    fontSize: 24,
                  ),
                  TimeSlot(
                    options: _hours,
                    controller: _hourController,
                    onChanged: (value) {
                      setState(() {
                        _hour = value;
                      });
                      _updateAlarm();
                    },
                    highlightIndex: _hour - 1,
                    textFormatter: (val) => val.toString().padLeft(2, '0'),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    ":",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  TimeSlot(
                    options: _minutes,
                    controller: _minuteController,
                    onChanged: (value) {
                      setState(() {
                        _minute = value;
                      });
                      _updateAlarm();
                    },
                    highlightIndex: _minute,
                    textFormatter: (val) => val.toString().padLeft(2, '0'),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 320,
                      minHeight: 60,
                      maxHeight: 60,
                    ),
                    child: SizedBox.expand(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(58, 110, 255, 0.16),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TimeSlot<T> extends StatelessWidget {
  final List<T> options;
  final ValueChanged<T> onChanged;
  final int highlightIndex;
  final FixedExtentScrollController controller;
  final String Function(T)? textFormatter;
  final double? fontSize;

  const TimeSlot({
    super.key,
    required this.options,
    required this.onChanged,
    required this.highlightIndex,
    required this.controller,
    this.textFormatter,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 240,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 60,
            perspective: 0.002,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              onChanged(options[index]);
              HapticFeedback.heavyImpact();
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: options.length,
              builder: (context, index) {
                if (index < 0 || index >= options.length) return null;

                final isSelected = index == highlightIndex;
                final displayText =
                    textFormatter?.call(options[index]) ??
                    options[index].toString();

                final distance = (index - highlightIndex).abs();
                final scale = (1.0 - distance * 0.1).clamp(0.8, 1.0);
                final fade = (1.0 - distance * 0.25).clamp(0.2, 1.0);

                return GestureDetector(
                  onTap: () {
                    controller.animateToItem(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                    onChanged(options[index]);
                    HapticFeedback.selectionClick();
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Center(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontFamily: 'Seven_Segment',
                        fontSize: fontSize ?? (52 * scale),
                        color:
                            isSelected
                                ? AppColors.white
                                : Color(0xFF87A8FF).withOpacity(fade),
                        height: 1.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
