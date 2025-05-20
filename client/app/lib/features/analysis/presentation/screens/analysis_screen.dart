import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_report.dart';
import 'package:sleep_tight/features/analysis/data/services/sleep_report_service.dart';
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
  late Future<List<SleepReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      Future.microtask(() {
        ref.read(selectedDateProvider.notifier).update(widget.initialDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    _reportsFuture = fetchSleepReports(ref, selectedDate);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnalysisHeader(),
          SizedBox(height: 4),
          WeekDateSelector(),
          SizedBox(height: 4),

          Expanded(
            child: FutureBuilder<List<SleepReport>>(
              future: _reportsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reports = snapshot.data!;
                if (reports.isEmpty) {
                  return const Center(child: Text("리포트가 없습니다."));
                }

                return AnalysisTab(reports: reports);
              },
            ),
          ),
        ],
      ),
    );
  }
}
