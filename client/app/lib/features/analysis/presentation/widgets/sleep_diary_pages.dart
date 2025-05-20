import 'package:flutter/material.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/features/analysis/data/models/sleep_report.dart';
import 'package:sleep_tight/features/analysis/presentation/screens/sleep_diary_view.dart';
import 'package:sleep_tight/features/analysis/presentation/widgets/page_indicator.dart';

class SleepDiaryPages extends StatefulWidget {
  final List<SleepReport> reports;
  final void Function(int)? onPageChanged;

  const SleepDiaryPages({super.key, required this.reports, this.onPageChanged});

  @override
  State<SleepDiaryPages> createState() => _SleepDiaryPagesState();
}

class _SleepDiaryPagesState extends State<SleepDiaryPages> {
  int _currentIndex = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.reports.length,
                onPageChanged: (i) {
                  setState(() => _currentIndex = i);
                  widget.onPageChanged?.call(i);
                },
                itemBuilder: (context, index) {
                  final report = widget.reports[index];
                  return SleepDiaryView(reportId: report.sleepReportId);
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: PageIndicator(
            total: widget.reports.length,
            current: _currentIndex,
            onChanged: (index) {
              _controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() => _currentIndex = index);
              widget.onPageChanged?.call(index);
            },
          ),
        ),
      ],
    );
  }
}
