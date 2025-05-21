import 'package:flutter/material.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_report_model.dart';
import 'package:sleep_tight/features/analysis/presentation/screens/sleep_report_view.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/sleep_diary_pages.dart';

class AnalysisTab extends StatefulWidget {
  final List<SleepReportModel> reports;
  final int initialTabIndex;
  final void Function(int index)? onTabChanged;

  const AnalysisTab({
    super.key,
    required this.reports,
    this.initialTabIndex = 0,
    this.onTabChanged,
  });

  @override
  State<AnalysisTab> createState() => _AnalysisTabState();
}

class _AnalysisTabState extends State<AnalysisTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentReportIndex = 0;
  late PageController _reportPageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        widget.onTabChanged?.call(_tabController.index);
      }
    });
    _reportPageController = PageController(initialPage: _currentReportIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reportPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reports = widget.reports;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          labelStyle: AppTextStyles.bodyB4Sb(color: AppColors.white),
          unselectedLabelColor: AppColors.font2,
          dividerColor: AppColors.gray06,
          dividerHeight: 0.2,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 1, color: AppColors.white),
          ),
          tabs: [Tab(text: "수면 리포트"), Tab(text: "수면 일지")],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SleepReportView(
                reports: reports,
                onPageChanged: (i) {
                  if (_currentReportIndex != i) {
                    setState(() => _currentReportIndex = i);
                  }
                },
              ),
              SleepDiaryPages(reports: reports),
            ],
          ),
        ),
      ],
    );
  }
}
