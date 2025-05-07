import 'package:app/core/config/theme/color.dart';
import 'package:flutter/material.dart';

class TimeSlotPicker extends StatefulWidget {
  const TimeSlotPicker({Key? key}) : super(key: key);

  @override
  _TimeSlotPickerState createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  String _amPm = '오전';
  int _hour = 7;
  int _minute = 0;

  final List<String> _amPmOptions = ['오전', '오후'];
  final List<int> _hours = List.generate(12, (index) => index + 1);
  final List<int> _minutes = List.generate(60, (index) => index);

  final FixedExtentScrollController _hourController =
      FixedExtentScrollController();
  final FixedExtentScrollController _minuteController =
      FixedExtentScrollController();
  final FixedExtentScrollController _amPmController =
      FixedExtentScrollController();

  String get formattedTime {
    final hourStr = _hour.toString().padLeft(2, '0');
    final minuteStr = _minute.toString().padLeft(2, '0');
    return '$_amPm $hourStr:$minuteStr';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hourController.jumpToItem(_hour - 1);
      _minuteController.jumpToItem(_minute);
      _amPmController.jumpToItem(_amPm == '오전' ? 0 : 1);
    });
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _amPmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
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
                    color: Color.fromRGBO(58, 110, 255, 0.16),
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
            ),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimeSlot(
              options: _amPmOptions,
              controller: _amPmController,
              onChanged: (value) {
                setState(() {
                  _amPm = value;
                });
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
              },
              highlightIndex: _minute,
              textFormatter: (val) => val.toString().padLeft(2, '0'),
            ),
          ],
        ),
      ],
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
    Key? key,
    required this.options,
    required this.onChanged,
    required this.highlightIndex,
    required this.controller,
    this.textFormatter,
    this.fontSize,
  }) : super(key: key);

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

                return Center(
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
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
