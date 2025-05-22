import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sleep_tight/features/user/data/models/enums/weight_unit.dart';
import 'package:sleep_tight/shared/widgets/custom_dropdown.dart';
import 'package:sleep_tight/shared/widgets/custom_text_field.dart';

class WeightFormField extends StatelessWidget {
  final String? initialWeightUnit;

  const WeightFormField({
    super.key,
    required this.formKey,
    this.initialWeightUnit,
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
            name: 'weight',
            hintText: '몸무게를 입력해주세요.',
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '몸무게를 입력하세요.'),
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
              (value) {
                final unit = formKey.currentState?.fields['weight_unit']?.value;
                if (value == null || value.isEmpty) return null;
                final num? weight = num.tryParse(value);
                if (weight == null) return null;
                if (unit == 'kg') {
                  if (weight < 20 || weight > 300) {
                    return '몸무게(kg)는 20~300 사이여야 합니다.';
                  }
                } else if (unit == 'lb') {
                  if (weight < 44 || weight > 660) {
                    return '몸무게(lb)는 44~660 사이여야 합니다.';
                  }
                }
                return null;
              },
            ]),
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          flex: 1,
          child: Align(
            alignment: Alignment.topLeft,
            child: CustomDropdown(
              name: 'weight_unit',
              initialValue: initialWeightUnit ?? WeightUnit.kg.value,
              values: WeightUnit.values.map((u) => u.value).toList(),
              validator: FormBuilderValidators.required(
                errorText: '몸무게 단위를 선택하세요.',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
