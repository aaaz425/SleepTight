import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sleep_tight/shared/widgets/custom_text_field.dart';

class NameFormField extends StatelessWidget {
  const NameFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            name: 'last_name',
            label: '성',
            hintText: '성을 입력해주세요.',
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '성을 입력하세요.'),
              FormBuilderValidators.maxLength(20, errorText: '20자 이하로 입력하세요.'),
            ]),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: CustomTextField(
            name: 'first_name',
            label: '이름',
            hintText: '이름을 입력해주세요.',
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '이름을 입력하세요.'),
              FormBuilderValidators.maxLength(20, errorText: '20자 이하로 입력하세요.'),
            ]),
          ),
        ),
      ],
    );
  }
}
