import 'package:flutter_riverpod/flutter_riverpod.dart';

final sleepStartTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());
