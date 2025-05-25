import 'package:flutter/material.dart';

enum WeightUnit {
  kg,
  lb;

  String get value => switch (this) {
    WeightUnit.kg => 'kg',
    WeightUnit.lb => 'lb',
  };

  static WeightUnit? fromValue(String? val) {
    if (val == null) return null;
    for (final unit in values) {
      if (unit.value.toLowerCase() == val.toLowerCase()) {
        return unit;
      }
    }
    debugPrint('Warning: Unknown WeightUnit string value encountered: $val');
    return null; // 또는 기본값 혹은 예외 처리
  }
}
