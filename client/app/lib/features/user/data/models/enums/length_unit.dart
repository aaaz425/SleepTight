import 'package:flutter/material.dart';

enum LengthUnit {
  cm,
  ftIn; // Represents "ft/in"

  String get value => switch (this) {
    LengthUnit.cm => 'cm',
    LengthUnit.ftIn => 'ft/in',
  };

  static LengthUnit? fromValue(String? val) {
    if (val == null) return null;
    for (final unit in values) {
      if (unit.value.toLowerCase() == val.toLowerCase()) {
        return unit;
      }
    }
    debugPrint('Warning: Unknown LengthUnit string value encountered: $val');
    return null; // 또는 기본값 혹은 예외 처리
  }
}
