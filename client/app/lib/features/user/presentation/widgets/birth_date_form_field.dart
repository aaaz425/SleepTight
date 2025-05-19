import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sleep_tight/shared/widgets/custom_dropdown.dart';

class BirthDateFormField extends StatelessWidget {
  const BirthDateFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomDropdown(
            name: 'year',
            initialValue: null,
            hintText: 'YYYY',
            validator: FormBuilderValidators.required(errorText: '년도를 선택하세요.'),
            values: List.generate(
              100,
              (index) => (2025 - 100 + index).toString(),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: CustomDropdown(
            name: 'month',
            initialValue: null,
            hintText: 'MM',
            validator: FormBuilderValidators.required(errorText: '월을 선택하세요.'),
            values: List.generate(12, (index) => (index + 1).toString()),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: CustomDropdown(
            name: 'day',
            initialValue: null,
            hintText: 'DD',
            validator: FormBuilderValidators.required(errorText: '일을 선택하세요.'),
            values: List.generate(31, (index) => (index + 1).toString()),
          ),
        ),
      ],
    );
  }
}
