import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/shared/widgets/custom_text_field.dart';
import 'package:sleep_tight/shared/widgets/modal_button.dart';

/// Shows a centered dialog to input the wake-up count. Returns the entered count or null.
Future<int?> showWakeCountModal({
  required BuildContext context,
  int initialCount = 0,
}) {
  return showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder:
        (_) => Center(
          child: Material(
            color: Colors.transparent,
            child: _WakeCountPicker(initialCount: initialCount),
          ),
        ),
  );
}

class _WakeCountPicker extends StatefulWidget {
  final int initialCount;
  const _WakeCountPicker({this.initialCount = 0});

  @override
  State<_WakeCountPicker> createState() => _WakeCountPickerState();
}

class _WakeCountPickerState extends State<_WakeCountPicker> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.gray01,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '자다 깬 횟수 입력',
            style: AppTextStyles.button3Md(color: AppColors.white),
          ),
          const SizedBox(height: 32),
          FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: CustomTextField(
                    name: 'wakeCount',
                    hintText: '0',
                    initialValue: widget.initialCount.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: '횟수를 입력해주세요'),
                      FormBuilderValidators.numeric(errorText: '숫자만 입력 가능합니다'),
                      FormBuilderValidators.min(0, errorText: '0 이상이어야 합니다'),
                    ]),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '회',
                  style: AppTextStyles.bodyB4Rg(color: AppColors.font2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ModalButton(
                text: '취소',
                textStyle: AppTextStyles.button3Md(color: AppColors.font1),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              ModalButton(
                text: '확인',
                textStyle: AppTextStyles.button3Md(color: AppColors.primaryHv),
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    final v = _formKey.currentState!.value;
                    final count =
                        int.tryParse(v['wakeCount']) ?? widget.initialCount;
                    Navigator.pop(context, count);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
