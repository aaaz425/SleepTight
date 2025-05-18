import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SleepDiaryView extends ConsumerWidget {
  const SleepDiaryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final diary = ref.watch(sleepDiaryProvider);

    // return diary.when(
    //   data:
    //       (entries) => ListView.builder(
    //         itemCount: entries.length,
    //         itemBuilder:
    //             (context, index) => ListTile(title: Text(entries[index].title)),
    //       ),
    //   loading: () => const Center(child: CircularProgressIndicator()),
    //   error: (err, _) => Center(child: Text('오류: $err')),
    // );

    return Text('수면 일지');
  }
}
