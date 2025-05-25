import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/music/presentation/providers/audio_controller.dart';
import 'package:sleep_tight/main.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioControllerProvider);
    final music = audioState.music;
    final audioController = ref.read(audioControllerProvider.notifier);

    if (music == null) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        final playerNotifier = ref.read(playerExpandProgressProvider);

        double currentPercentage = playerNotifier.value;
        double dragDelta = -details.delta.dy;

        double screenHeight = MediaQuery.of(context).size.height;
        double sensitivityFactor = 0.6;
        double changeInPercentage =
            dragDelta / (screenHeight * sensitivityFactor);

        double newPercentage = (currentPercentage + changeInPercentage).clamp(
          0.0,
          1.0,
        );
        playerNotifier.value = newPercentage;

        debugPrint(
          'Custom MiniPlayer Drag Update: newPercentage=$newPercentage',
        );
      },
      onVerticalDragEnd: (details) {
        final playerNotifier = ref.read(playerExpandProgressProvider);
        final audioCtrl = ref.read(audioControllerProvider.notifier);

        double currentProgress = playerNotifier.value;
        double velocity = details.primaryVelocity ?? 0.0;

        const double fastSwipeUpVelocity = -500;
        const double fastSwipeDownVelocity = 500;
        const double dismissThresholdProgress = 0.1;
        const double gentleSwipeDownVelocity = 100;

        if (velocity < fastSwipeUpVelocity) {
          playerNotifier.value = 1.0;
          debugPrint(
            'MiniPlayer: Swiped Up. Expanding. New progress: ${playerNotifier.value}',
          );
        } else if (velocity > fastSwipeDownVelocity ||
            (currentProgress < dismissThresholdProgress &&
                velocity > gentleSwipeDownVelocity)) {
          audioCtrl.stop();
          playerNotifier.value = 0.0;
          debugPrint(
            'MiniPlayer: Swiped Down to Dismiss. Music stopped. Progress reset.',
          );
        } else {
          if (currentProgress >= 0.2) {
            playerNotifier.value = currentProgress.clamp(0.2, 1.0);
          } else {
            playerNotifier.value = 0.0;
          }
          debugPrint(
            'MiniPlayer: Drag End (Slow/Ambiguous). Final progress: ${playerNotifier.value}',
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gray01,
          border: Border(
            top: BorderSide(color: AppColors.font1, width: 0.25),
            bottom: BorderSide(color: AppColors.font1, width: 0.25),
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: SizedBox(
            height: 52,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      music.coverUrl,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (ctx, err, st) => Icon(
                            Icons.broken_image,
                            color: AppColors.gray06,
                            size: 30,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      music.title,
                      style: AppTextStyles.captionC1Rg(
                        color: AppColors.white,
                      ).copyWith(decoration: TextDecoration.none),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      debugPrint("MiniPlayer: Play/Pause button tapped");
                      if (audioState.isPlaying) {
                        audioController.pause();
                      } else {
                        audioController.play(music);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        audioState.isPlaying
                            ? 'assets/icons/pause_solid.svg'
                            : 'assets/icons/play_solid.svg',
                        colorFilter: ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
