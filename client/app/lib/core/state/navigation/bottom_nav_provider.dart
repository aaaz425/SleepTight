import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bottom_nav_provider.g.dart';

@riverpod
class BottomNavIndex extends _$BottomNavIndex {
  @override
  int build() => 0;

  void set(int index) {
    state = index;
  }
}
