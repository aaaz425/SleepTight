import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_provider.g.dart';

@riverpod
class UserName extends _$UserName {
  @override
  String build() => 'Guest';

  void change(String newName) {
    state = newName;
  }
}
