import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sleep_tight/features/user/data/models/enums/length_unit.dart';
import 'package:sleep_tight/shared/widgets/custom_dropdown.dart';
import 'package:sleep_tight/shared/widgets/custom_text_field.dart';

class HeightFormField extends StatelessWidget {
  final String? initialLengthUnit;

  const HeightFormField({
    super.key,
    required this.formKey,
    this.initialLengthUnit,
  });

  final GlobalKey<FormBuilderState> formKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 2,
          child: CustomTextField(
            name: 'height',
            hintText: '키를 입력해주세요.',
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '키를 입력하세요.'),
              FormBuilderValidators.numeric(errorText: '숫자만 입력하세요.'),
              // 소수 둘째자리까지 가능
              (value) {
                if (value == null || value.isEmpty) return null;
                // 입력 문자열로 소수 자릿수 검사
                final parts = value.split('.');
                if (parts.length > 1 && parts[1].length > 2) {
                  return '소수 둘째자리까지만 입력 가능합니다.';
                }
                return null;
              },
              // length_unit에 따라서 validation 다르게 적용
              // cm면 100이상 300 이하
              // ft/in면 3이상 10 이하
              (value) {
                final unit = formKey.currentState?.fields['length_unit']?.value;
                if (value == null || value.isEmpty) return null;
                final num? height = num.tryParse(value);
                if (height == null) return null;

                if (unit == 'cm') {
                  if (height < 100 || height > 300) {
                    return '키(cm)는 100~300 사이여야 합니다.';
                  }
                } else if (unit == 'ft/in') {
                  if (height < 3 || height > 10) {
                    return '키(ft/in)는 3~10 사이여야 합니다.';
                  }
                }
                return null;
              },
            ]),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.topLeft,
            child: CustomDropdown(
              name: 'length_unit',
              initialValue: initialLengthUnit ?? LengthUnit.cm.value,
              values: LengthUnit.values.map((u) => u.value).toList(),
              validator: FormBuilderValidators.required(
                errorText: '길이 단위를 선택하세요.',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
