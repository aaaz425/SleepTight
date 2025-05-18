import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:sleep_tight/shared/widgets/custom_dropdown.dart';
import 'package:sleep_tight/features/user/data/models/enums/country.dart';

class CountryFormField extends StatelessWidget {
  const CountryFormField({super.key, required this.initialValue});

  final Country? initialValue;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      key: ValueKey(initialValue?.getDisplayName('ko') ?? ''),
      name: 'country',
      initialValue: initialValue?.getDisplayName('ko'),
      hintText: '선택',
      validator: FormBuilderValidators.required(errorText: '국적을 선택하세요.'),
      values: Country.values.map((c) => c.getDisplayName('ko')).toList(),
    );
  }
}
