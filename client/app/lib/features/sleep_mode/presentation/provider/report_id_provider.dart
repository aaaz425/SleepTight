import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_id_provider.g.dart';

@riverpod
class ReportIdNotifier extends _$ReportIdNotifier {
  @override
  int build() => 0;

  void set(int newId) => state = newId;

  void clear() => state = 0;
}
