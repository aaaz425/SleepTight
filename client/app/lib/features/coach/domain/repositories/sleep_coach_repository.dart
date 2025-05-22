import 'package:sleep_tight/features/coach/data/models/requests/create_sleep_coaching_request.dart';

abstract interface class SleepCoachRepository {
  Future<void> createSleepCoach(CreateSleepCoachingRequest request);
}
