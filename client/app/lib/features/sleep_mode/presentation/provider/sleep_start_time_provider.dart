import 'package:flutter_riverpod/flutter_riverpod.dart';

final sleepStartTimeProvider = StateProvider<String>(
  (ref) => DateTime.now().toIso8601String(),
);
