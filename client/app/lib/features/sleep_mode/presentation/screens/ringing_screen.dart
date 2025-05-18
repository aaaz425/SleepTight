import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/utils/overlay.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/provider/alarm_provider.dart';
import 'package:sleep_tight/features/sleep_mode/presentation/screens/wake_up_screen.dart';

class RingingScreen extends ConsumerStatefulWidget {
  const RingingScreen({super.key});

  @override
  ConsumerState<RingingScreen> createState() => _RingingScreenState();
}

class _RingingScreenState extends ConsumerState<RingingScreen> {
  late final AudioPlayer _player;
  late Timer _overlayTimer;
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startAlarm();
    _startWakeUpOverlayTimer();
    _startClock();
  }

  void _startAlarm() async {
    _player = AudioPlayer();
    await _player.setAsset('assets/sound/alarm.mp3');
    _player.setLoopMode(LoopMode.one);
    _player.play();
  }

  void _startWakeUpOverlayTimer() {
    // Memo: 5분간 일어나지 않으면 강제로 기상화면
    _overlayTimer = Timer(const Duration(minutes: 5), () async {
      await _player.stop();
      if (!mounted) return;
      showOverlay(context: context, child: WakeUpScreen());
    });
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _overlayTimer.cancel();
    _clockTimer.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'MM월 dd일 EEEE',
      'ko_KR',
    ).format(_now);
    final String formattedTime = DateFormat('a hh:mm', 'ko_KR').format(_now);

    return Scaffold(
      backgroundColor: const Color(0xFFDFDFE5),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 16, color: AppColors.gray01),
          ),
          const SizedBox(height: 72),
          Text(
            formattedTime,
            style: const TextStyle(
              fontSize: 32,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Image.asset(
              'assets/images/wake_up.png',
              width: 200,
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(height: 125),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildButton(
                  context,
                  ref,
                  label: '알람 끄기',
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  onPressed: () async {
                    await _player.stop();
                    if (!context.mounted) return;
                    Navigator.of(context).pop();

                    showOverlay(context: context, child: WakeUpScreen());
                  },
                ),
                const SizedBox(height: 10),
                _buildButton(
                  context,
                  ref,
                  label: '5분 뒤 다시 알람',
                  backgroundColor: const Color(0xFFDFDFE5),
                  textColor: AppColors.primaryHv,
                  onPressed: () async {
                    await ref
                        .read(alarmTimeNotifierProvider.notifier)
                        .snoozeAlarm();
                    ref.invalidate(alarmTimeNotifierProvider);

                    if (mounted && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: textColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: onPressed,
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
