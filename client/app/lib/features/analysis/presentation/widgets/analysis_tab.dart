import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sleep_tight/core/config/app_config.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/analysis/presentation/providers/selected_date_provider.dart';
import 'package:sleep_tight/features/analysis/presentation/screens/sleep_diary_view.dart';
import 'package:sleep_tight/features/analysis/presentation/screens/sleep_report_page_view.dart';

class AnalysisTab extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const AnalysisTab({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<AnalysisTab> createState() => _AnalysisTabState();
}

class _AnalysisTabState extends ConsumerState<AnalysisTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final index = _tabController.index;
      final tab = index == 0 ? 'report' : 'diary';
      context.go('${AppConfig.routes.sleepAnalysis}?tab=$tab');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.font2,
          dividerColor: AppColors.gray06,
          dividerHeight: 0.2,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 1, color: AppColors.white),
          ),
          tabs: [Tab(text: '수면 리포트'), Tab(text: '수면 일지')],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              SleepReportPageView(date: selectedDate),
              SleepDiaryView(),
            ],
          ),
        ),
      ],
    );
  }
}
