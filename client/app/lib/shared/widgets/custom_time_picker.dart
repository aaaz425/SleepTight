import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:group_button/group_button.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/shared/widgets/custom_text_field.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sleep_tight/shared/widgets/modal_button.dart';

// 여러 시간 폼을 구분할 enum
enum CustomTimePickerForm { sleepGoal, sleepStart, wakeUp }

/// Shows a centered dialog to pick a time. Returns selected TimeOfDay or null.
Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  int initialHour = 0,
  int initialMinute = 0,
  bool showPeriodPicker = false,
  CustomTimePickerForm formType = CustomTimePickerForm.sleepGoal,
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
              formType: formType,
            ),
          ),
        ),
  );
}

class _CustomTimePicker extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final bool showPeriodPicker;
  final CustomTimePickerForm formType;

  const _CustomTimePicker({
    this.initialHour = 0,
    this.initialMinute = 0,
    this.showPeriodPicker = false,
    this.formType = CustomTimePickerForm.sleepGoal,
  });

  @override
  State<_CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<_CustomTimePicker> {
  late int hour;
  late int minute;
  late String period; // '오전' or '오후'
  late String title;
  late final GroupButtonController _periodController;
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    // title 설정
    switch (widget.formType) {
      case CustomTimePickerForm.sleepGoal:
        title = '목표 수면 시간 설정';
        break;
      case CustomTimePickerForm.sleepStart:
        title = '수면 시작 시간 설정';
        break;
      case CustomTimePickerForm.wakeUp:
        title = '기상 시간 설정';
        break;
    }
    var h = widget.initialHour;
    period = h >= 12 ? '오후' : '오전';
    // 초기 선택 인덱스 설정
    _periodController = GroupButtonController(
      selectedIndex: period == '오전' ? 0 : 1,
    );
    if (widget.showPeriodPicker) {
      // convert to 12h
      hour = h % 12;
      if (hour == 0) hour = 12;
    } else {
      hour = h;
    }
    minute = widget.initialMinute;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.gray01,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8),
        ), // 전체 다이얼로그 모서리 둥글게 하려면 전체
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/clock.svg',
                      width: 28,
                      height: 28,
                      colorFilter: ColorFilter.mode(
                        AppColors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      title,
                      style: AppTextStyles.button3Md(color: AppColors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Period Picker (오전/오후) - showPeriodPicker가 true일 때 표시
                    if (widget.showPeriodPicker)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            GroupButton<String>(
                              controller: _periodController,
                              options: GroupButtonOptions(
                                direction: Axis.vertical,
                                spacing: 0,
                              ),
                              buttonBuilder: (
                                bool selected,
                                String value,
                                BuildContext context,
                              ) {
                                return Container(
                                  width: 48,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color:
                                        selected
                                            ? Color(0x1FFFFFFF) // #ffffff 8%
                                            : Colors.transparent,
                                    borderRadius:
                                        value == '오전'
                                            ? BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6),
                                            )
                                            : BorderRadius.only(
                                              bottomLeft: Radius.circular(6),
                                              bottomRight: Radius.circular(6),
                                            ),
                                    border: Border.all(
                                      color: AppColors.gray05,
                                      width: 0.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    value,
                                    style: AppTextStyles.bodyB4Rg(
                                      color:
                                          selected
                                              ? AppColors.white
                                              : AppColors.font3,
                                    ),
                                  ),
                                );
                              },
                              isRadio: true,
                              onSelected: (value, index, isSelected) {
                                setState(() {
                                  period = value;
                                });
                              },
                              buttons: const ['오전', '오후'],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),

                    // Hours
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 108,
                          height: 72,
                          child: CustomTextField(
                            name: 'hours',
                            hintText: '00',
                            initialValue: hour.toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: '시간을 입력해주세요',
                              ),
                              FormBuilderValidators.numeric(
                                errorText: '숫자만 입력 가능합니다',
                              ),
                              FormBuilderValidators.min(
                                1,
                                errorText: '시간은 1 이상이어야 합니다',
                              ),
                              FormBuilderValidators.max(
                                12,
                                errorText: '시간은 12 이하이어야 합니다',
                              ),
                            ]),
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
                          width: 108,
                          height: 72,
                          child: CustomTextField(
                            name: 'minutes',
                            hintText: '00',
                            initialValue: minute.toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: '분을 입력해주세요',
                              ),
                              FormBuilderValidators.numeric(
                                errorText: '숫자만 입력 가능합니다',
                              ),
                              FormBuilderValidators.min(
                                0,
                                errorText: '분은 0 이상이어야 합니다',
                              ),
                              FormBuilderValidators.max(
                                59,
                                errorText: '분은 59 이하이어야 합니다',
                              ),
                            ]),
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

              SizedBox(height: 1), // 간격 조정
              // 취소, 확인 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ModalButton(
                    text: '취소',
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 4),
                  ModalButton(
                    text: '확인',
                    textStyle: AppTextStyles.button3Md(
                      color: AppColors.primaryHv,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        final v = _formKey.currentState!.value;
                        int h = int.parse(v['hours']);
                        int m = int.parse(v['minutes']);
                        if (widget.showPeriodPicker) {
                          if (period == '오후' && h != 12) h += 12;
                          if (period == '오전' && h == 12) h = 0;
                        }
                        Navigator.pop(context, TimeOfDay(hour: h, minute: m));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
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
      height: 72, // CustomTextField의 높이와 동일하게 설정
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
      height: 72,
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
