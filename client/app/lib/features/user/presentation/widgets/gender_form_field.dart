import 'package:flutter/material.dart';
import 'package:sleep_tight/features/user/data/models/enums/gender.dart';
import 'package:sleep_tight/shared/widgets/custom_radio_group.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class GenderFormField extends StatelessWidget {
  final Gender? initialValue;

  const GenderFormField({super.key, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return CustomRadioGroup<Gender>(
      name: 'gender',
      initialValue: initialValue ?? Gender.male,
      options: Gender.values,
      labels: Gender.values.map((gender) => gender.ko).toList(),
      selectedColor: AppColors.primary,
      unselectedColor: Colors.transparent,
      borderColor: AppColors.gray06,
      validator: FormBuilderValidators.required(errorText: '성별을 선택하세요.'),
      direction: Axis.horizontal,
    );
  }
}
