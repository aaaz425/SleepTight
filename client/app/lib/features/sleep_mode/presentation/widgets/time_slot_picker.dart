import 'package:flutter/material.dart';

class TimeSlotPicker extends StatefulWidget {
  const TimeSlotPicker({Key? key}) : super(key: key);

  @override
  _TimeSlotPickerState createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  String _amPm = '오전'; // 오전/오후
  int _hour = 7; // 시간 (기본값 오전 7시)
  int _minute = 0; // 분

  // 슬롯의 항목들 (1 ~ 12시, 00 ~ 59분, AM/PM)
  final List<String> _amPmOptions = ['오전', '오후'];
  final List<int> _hours = List.generate(12, (index) => index + 1);
  final List<int> _minutes = List.generate(60, (index) => index);

  // FixedExtentScrollController를 사용하도록 변경
  final FixedExtentScrollController _hourController =
      FixedExtentScrollController();
  final FixedExtentScrollController _minuteController =
      FixedExtentScrollController();
  final FixedExtentScrollController _amPmController =
      FixedExtentScrollController();

  String get formattedTime {
    return '$_hour:${_minute.toString().padLeft(2, '0')} $_amPm';
  }

  @override
  void initState() {
    super.initState();
    // 기본값인 오전 7시로 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hourController.jumpToItem(_hour - 1); // 초기화 시 7시가 가운데로 오게
      _minuteController.jumpToItem(_minute); // 분 설정
      _amPmController.jumpToItem(_amPm == '오전' ? 0 : 1); // 오전/오후 설정
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 시간 슬롯
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimeSlot(
              options: _hours,
              controller: _hourController,
              onChanged: (value) {
                setState(() {
                  _hour = value;
                });
              },
              highlightIndex: _hour - 1,
            ),
            const SizedBox(width: 10),
            const Text(":", style: TextStyle(fontSize: 32)),
            const SizedBox(width: 10),
            TimeSlot(
              options: _minutes,
              controller: _minuteController,
              onChanged: (value) {
                setState(() {
                  _minute = value;
                });
              },
              highlightIndex: _minute,
            ),
            const SizedBox(width: 10),
            TimeSlot(
              options: _amPmOptions,
              controller: _amPmController,
              onChanged: (value) {
                setState(() {
                  _amPm = value;
                });
              },
              highlightIndex: _amPm == '오전' ? 0 : 1,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '선택된 시간: $formattedTime',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class TimeSlot<T> extends StatelessWidget {
  final List<T> options;
  final ValueChanged<T> onChanged;
  final int highlightIndex; // 강조할 항목의 인덱스
  final FixedExtentScrollController controller;

  const TimeSlot({
    Key? key,
    required this.options,
    required this.onChanged,
    required this.highlightIndex,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 200,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40, // 항목 크기
        perspective: 0.005, // 회전 효과 강도
        diameterRatio: 1.5, // 깊이 효과
        physics:
            const FixedExtentScrollPhysics(), // FixedExtentScrollPhysics 사용
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final isSelected = index == highlightIndex;
            return GestureDetector(
              onTap: () => onChanged(options[index]),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withOpacity(0.5) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      options[index].toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: options.length,
        ),
      ),
    );
  }
}
