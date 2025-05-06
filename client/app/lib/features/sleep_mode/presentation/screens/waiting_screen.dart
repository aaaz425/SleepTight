import 'package:flutter/material.dart';

import '../widgets/time_slot_picker.dart';

class WaitingScreen extends StatelessWidget {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.timer_outlined, size: 28),
            SizedBox(width: 4),
            Text(
              '알람 시간을 설정해보세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),

        const SizedBox(height: 40),

        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: TimeSlotPicker(),
          ),
        ),

        const SizedBox(height: 6),
      ],
    );
  }
}
