import 'package:flutter/material.dart';

class SleepingScreen extends StatelessWidget {
  const SleepingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Image.asset(
            'assets/images/clock.png',
            width: 200,
            fit: BoxFit.fitWidth,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              '알람을 설정해보세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ],
    );
  }
}
