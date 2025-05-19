import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/features/analysis/presentation/providers/selected_date_provider.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/analysis_header.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/analysis_tab.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/week_date_selector.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final DateTime? initialDate;

  const AnalysisScreen({super.key, this.initialTabIndex = 0, this.initialDate});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  @override
  void initState() {
    super.initState();

    // 만약 initialDate가 주어졌다면 provider를 초기화
    if (widget.initialDate != null) {
      Future.microtask(() {
        ref.read(selectedDateProvider.notifier).update(widget.initialDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalysisHeader(),
          SizedBox(height: 4),
          WeekDateSelector(),
          SizedBox(height: 4),
          Expanded(child: AnalysisTab(initialTabIndex: widget.initialTabIndex)),
        ],
      ),
    );
  }
}
