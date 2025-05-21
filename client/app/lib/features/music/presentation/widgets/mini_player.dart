import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/music/presentation/providers/audio_controller.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioControllerProvider);
    final music = audioState.music;
    if (music == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray01,
        border: Border(
          top: BorderSide(color: AppColors.font1, width: 0.25),
          bottom: BorderSide(color: AppColors.font1, width: 0.25),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const SizedBox(width: 12),
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
                          size: 48,
                        ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    music.title,
                    style: AppTextStyles.captionC1Rg(
                      color: AppColors.white,
                    ).copyWith(decoration: TextDecoration.none),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    overlayColor: WidgetStateProperty.resolveWith(
                      (states) =>
                          states.contains(WidgetState.pressed)
                              ? AppColors.white.withValues(alpha: 0.2)
                              : null,
                    ),
                    onTap: () {
                      if (audioState.isPlaying) {
                        ref.read(audioControllerProvider.notifier).pause();
                      } else {
                        ref.read(audioControllerProvider.notifier).play(music);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        audioState.isPlaying
                            ? 'assets/icons/pause_solid.svg'
                            : 'assets/icons/play_solid.svg',
                        colorFilter: ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
