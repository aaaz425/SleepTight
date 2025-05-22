enum ActivityUnit {
  liter,
  second,
  step,
  kilocalorie,
  grams;

  factory ActivityUnit.fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LITER':
        return ActivityUnit.liter;
      case 'SECOND':
        return ActivityUnit.second;
      case 'STEP':
        return ActivityUnit.step;
      case 'KILOCALORIE':
        return ActivityUnit.kilocalorie;
      case 'GRAMS':
        return ActivityUnit.grams;
      default:
        throw ArgumentError('Unknown ActivityUnit: $value');
    }
  }

  String get label {
    switch (this) {
      case ActivityUnit.liter:
        return 'L';
      case ActivityUnit.second:
        return '초';
      case ActivityUnit.step:
        return '걸음';
      case ActivityUnit.kilocalorie:
        return 'kcal';
      case ActivityUnit.grams:
        return 'g';
    }
  }

  String get koreanName {
    switch (this) {
      case ActivityUnit.liter:
        return '리터';
      case ActivityUnit.second:
        return '초';
      case ActivityUnit.step:
        return '걸음';
      case ActivityUnit.kilocalorie:
        return '킬로칼로리';
      case ActivityUnit.grams:
        return '그램';
    }
  }
}
