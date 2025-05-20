// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:sleep_tight/features/analysis/data/models/sleep_report.dart';
// import 'package:sleep_tight/features/analysis/data/services/sleep_report_service.dart';
// import 'package:sleep_tight/features/analysis/presentation/screens/sleep_report_view.dart';

// class SleepReportPageView extends ConsumerStatefulWidget {
//   final DateTime date;
//   const SleepReportPageView({super.key, required this.date});

//   @override
//   ConsumerState<SleepReportPageView> createState() =>
//       _SleepReportPageViewState();
// }

// class _SleepReportPageViewState extends ConsumerState<SleepReportPageView> {
//   late Future<List<SleepReport>> _reportsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _reportsFuture = fetchSleepReports(ref, widget.date);
//   }

//   @override
//   void didUpdateWidget(covariant SleepReportPageView oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.date != widget.date) {
//       setState(() {
//         _reportsFuture = fetchSleepReports(ref, widget.date);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<SleepReport>>(
//       future: _reportsFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('에러: ${snapshot.error}'));
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(child: Text('해당 날짜에 수면 리포트가 없습니다.'));
//         }

//         final reports = snapshot.data ?? [];
//         return PageView.builder(
//           itemCount: reports.length,
//           itemBuilder: (context, index) {
//             return SleepReportView(report: reports[index]);
//           },
//         );
//       },
//     );
//   }
// }
