import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/shared/widgets/custom_button.dart';
import 'package:sleep_tight/shared/widgets/custom_text_field.dart';

/// Shows a centered dialog to pick a time. Returns selected TimeOfDay or null.
Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  int initialHour = 0,
  int initialMinute = 0,
  bool showPeriodPicker = false,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    barrierDismissible: true,
    builder:
        (_) => Center(
          child: Material(
            color: Colors.transparent,
            child: _CustomTimePicker(
              initialHour: initialHour,
              initialMinute: initialMinute,
              showPeriodPicker: showPeriodPicker,
            ),
          ),
        ),
  );
}

class _CustomTimePicker extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final bool showPeriodPicker;

  const _CustomTimePicker({
    this.initialHour = 0,
    this.initialMinute = 0,
    this.showPeriodPicker = false,
  });

  @override
  State<_CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<_CustomTimePicker> {
  late int hour;
  late int minute;
  late String period; // '오전' or '오후'

  // TextEditingControllers for hours and minutes to manage input and validation
  late TextEditingController _hourController;
  late TextEditingController _minuteController;

  @override
  void initState() {
    super.initState();
    var h = widget.initialHour;
    period = h >= 12 ? '오후' : '오전';
    if (widget.showPeriodPicker) {
      // convert to 12h
      hour = h % 12;
      if (hour == 0) hour = 12; // 0시(자정) 또는 12시(정오)는 12로 표시
    } else {
      hour = h;
    }
    minute = widget.initialMinute;

    _hourController = TextEditingController(
      text: hour.toString().padLeft(2, '0'),
    );
    _minuteController = TextEditingController(
      text: minute.toString().padLeft(2, '0'),
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    // 입력된 시간과 분을 가져옵니다.
    int currentHour = int.tryParse(_hourController.text) ?? hour;
    int currentMinute = int.tryParse(_minuteController.text) ?? minute;

    // 유효성 검사 (예: 시간은 0-23 또는 1-12, 분은 0-59)
    // showPeriodPicker에 따라 시간 범위 조정
    if (widget.showPeriodPicker) {
      if (currentHour < 1 || currentHour > 12) {
        // 간단한 알림 또는 에러 메시지 표시
        print("시간은 1에서 12 사이여야 합니다.");
        return;
      }
      if (period == '오후' && currentHour != 12) {
        // 오후 12시는 그대로 12시
        currentHour += 12;
      } else if (period == '오전' && currentHour == 12) {
        // 오전 12시(자정)는 0시로
        currentHour = 0;
      }
    } else {
      if (currentHour < 0 || currentHour > 23) {
        print("시간은 0에서 23 사이여야 합니다.");
        return;
      }
    }

    if (currentMinute < 0 || currentMinute > 59) {
      print("분은 0에서 59 사이여야 합니다.");
      return;
    }

    Navigator.pop(context, TimeOfDay(hour: currentHour, minute: currentMinute));
  }

  @override
  Widget build(BuildContext context) {
    // 전체 컨테이너 높이를 내용에 맞게 조절하거나, 고정값을 유지할 수 있습니다.
    // 여기서는 기존 높이 186을 유지합니다.
    return Container(
      width: 320,
      // height: 186, // Column의 MainAxisSize.min을 사용하면 내용에 맞게 높이가 조절될 수 있습니다.
      // 또는 고정 높이를 유지하고 내부 스크롤을 제공할 수도 있습니다.
      decoration: BoxDecoration(
        color: AppColors.gray01,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8),
        ), // 전체 다이얼로그 모서리 둥글게 하려면 전체
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 컬럼의 크기를 자식들 크기에 맞춤
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/clock.svg',
                    width: 28, // 아이콘 크기 지정 (선택 사항)
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "목표 수면 시간 설정",
                    style: AppTextStyles.button3Md(color: AppColors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Period Picker (오전/오후) - showPeriodPicker가 true일 때 표시
                  if (widget.showPeriodPicker)
                    Column(
                      children: [
                        Container(
                          // 오전/오후 선택 위젯의 높이를 다른 요소들과 맞춤
                          height: 70, // CustomTextField의 높이와 동일하게 설정
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(right: 8),
                          child: DropdownButton<String>(
                            // 간단한 드롭다운 예시
                            value: period,
                            dropdownColor: AppColors.gray01,
                            style: AppTextStyles.bodyB2Sb(
                              color: AppColors.white,
                            ),
                            iconEnabledColor: AppColors.white,
                            underline: Container(), // 밑줄 제거
                            items:
                                <String>[
                                  '오전',
                                  '오후',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  period = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),

                  // Hours
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width:
                            widget.showPeriodPicker
                                ? 70
                                : 106, // 오전/오후 선택 시 너비 조정
                        height: 70,
                        child: CustomTextField(
                          name: 'hours', // FormBuilder 사용 시 필요
                          // controller: _hourController, // 직접 컨트롤러 사용
                          hintText: '00',
                          textAlign: TextAlign.center, // 텍스트 필드 내부 텍스트 중앙 정렬
                          keyboardType: TextInputType.number,
                          // initialValue는 controller 사용 시 controller의 text로 대체
                        ),
                      ),
                      if (!widget.showPeriodPicker) ...[
                        SizedBox(width: 4),
                        TimeLabel(label: "시간"),
                      ],
                    ],
                  ),
                  if (!widget.showPeriodPicker) SizedBox(width: 12),

                  if (widget.showPeriodPicker) TimeSeparator(),

                  // Minutes
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width:
                            widget.showPeriodPicker
                                ? 70
                                : 108, // 오전/오후 선택 시 너비 조정
                        height: 70,
                        child: CustomTextField(
                          name: 'minutes', // FormBuilder 사용 시 필요
                          // controller: _minuteController, // 직접 컨트롤러 사용
                          hintText: '00',
                          textAlign: TextAlign.center, // 텍스트 필드 내부 텍스트 중앙 정렬
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      if (!widget.showPeriodPicker) ...[
                        SizedBox(width: 4),
                        TimeLabel(label: "분"),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16), // 간격 조정
            // 취소, 확인 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TimePickerButton(
                  text: '취소',
                  onPressed: () {
                    print('취소 버튼 눌림');
                  },
                ),
                SizedBox(width: 4),
                TimePickerButton(
                  text: '확인',
                  textStyle: AppTextStyles.button3Md(
                    color: AppColors.primaryHv,
                  ),
                  onPressed: () {
                    print('확인 버튼 눌림');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TimeLabel extends StatelessWidget {
  final String label;

  const TimeLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // "시간" 텍스트를 명시적으로 중앙 정렬
      height: 70, // CustomTextField의 높이와 동일하게 설정
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyles.bodyB4Rg(color: AppColors.font2),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class TimeSeparator extends StatelessWidget {
  const TimeSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 8,
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 원 2개 4x4
                // 사이 간격 8
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.font2,
                    shape: BoxShape.circle, // 원 모양으로 지정
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.font2,
                    shape: BoxShape.circle, // 원 모양으로 지정
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class TimePickerButton extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  const TimePickerButton({
    super.key,
    required this.text,
    this.textStyle,
    this.onPressed,
    this.width = 60.0,
    this.height = 34.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle defaultTextStyle = AppTextStyles.button3Md(
      color: AppColors.font1,
    );

    // textStyle이 null이 아니고 color도 지정되어 있다면 해당 색상 사용, 아니면 기본 텍스트 색상 사용
    final Color effectiveTextColor =
        textStyle?.color ?? defaultTextStyle.color!;

    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: padding,
          minimumSize: Size(width, height),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          foregroundColor: effectiveTextColor, // 텍스트 및 아이콘 기본 색상
        ).copyWith(
          // overlayColor는 ButtonStyle의 일부이므로, styleFrom() 내부 또는 copyWith() 내부에서
          // MaterialStateProperty (또는 WidgetStateProperty)를 사용해야 합니다.
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            // WidgetStateProperty도 가능
            (Set<WidgetState> states) {
              // Flutter 3.13+ 에서는 Set<WidgetState>
              if (states.contains(WidgetState.pressed)) {
                // WidgetState.pressed
                return effectiveTextColor.withValues(
                  alpha: 0.12,
                ); // 눌렀을 때 텍스트 색상 기반의 약한 오버레이
              }
              if (states.contains(WidgetState.hovered)) {
                // WidgetState.hovered
                return effectiveTextColor.withValues(
                  alpha: 0.08,
                ); // 호버 시 약한 오버레이
              }
              return null; // 기본값 (효과 없음)
            },
          ),
          visualDensity: VisualDensity.compact,
        ),
        child: Text(text, style: textStyle ?? defaultTextStyle),
      ),
    );
  }
}
