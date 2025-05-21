import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/music/data/models/enums/music_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/features/music/presentation/providers/audio_controller.dart';
import 'package:sleep_tight/features/music/presentation/providers/music_provider.dart';

class MusicCategoryList extends StatelessWidget {
  const MusicCategoryList({super.key, required this.category});

  final MusicCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MusicListHeader(category: category),
        _MusicList(category: category),
      ],
    );
  }
}

class _MusicList extends ConsumerWidget {
  const _MusicList({required this.category});
  final MusicCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicsAsync = ref.watch(musicsByCategoryProvider(category));
    return musicsAsync.when(
      loading:
          () => SizedBox(
            height: 150,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.font2,
                  strokeWidth: 4,
                ),
              ),
            ),
          ),
      error: (e, st) => Center(child: Text('Error: $e')),
      data:
          (musics) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    musics.map((music) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              debugPrint(music.title);
                              ref
                                  .read(audioControllerProvider.notifier)
                                  .play(music, context);
                            },
                            splashColor: Colors.white.withValues(alpha: 0.3),
                            highlightColor: Colors.white.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      music.coverUrl,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      music.title,
                                      style: AppTextStyles.bodyB2Rg(
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
    );
  }
}

class _MusicListHeader extends StatelessWidget {
  const _MusicListHeader({required this.category});

  final MusicCategory category;

  String _getCategoryTitle(MusicCategory category) {
    switch (category) {
      case MusicCategory.cozy:
        return '아늑한';
      case MusicCategory.nature:
        return '자연';
      case MusicCategory.dreamy:
        return '몽환적인';
      case MusicCategory.mystic:
        return '신비로운';
      case MusicCategory.healing:
        return '치유';
      case MusicCategory.focus:
        return '집중';
    }
  }

  String _getCategoryDescription(MusicCategory category) {
    switch (category) {
      case MusicCategory.cozy:
        return '음악과 함께 잠에 빠져들어보세요.';
      case MusicCategory.nature:
        return '음악과 함께 편안한 휴식을 취해보세요.';
      case MusicCategory.dreamy:
        return '음악과 함께 상상의 나래를 펼쳐보세요.';
      case MusicCategory.mystic:
        return '음악과 함께 새로운 영감을 얻어보세요.';
      case MusicCategory.healing:
        return '음악과 함께 마음에 위로를 받아보세요.';
      case MusicCategory.focus:
        return '음악과 함께 중요한 일에 몰입해보세요.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${_getCategoryTitle(category)} 음악",
                style: AppTextStyles.titleT3Sb(color: AppColors.font1),
              ),
              SizedBox(height: 2),
              Text(
                _getCategoryDescription(category),
                style: AppTextStyles.bodyB2Rg(color: AppColors.font2),
              ),
            ],
          ),
          SvgPicture.asset(
            'assets/icons/chevron_right.svg',
            width: 20,
            height: 20,
          ),
        ],
      ),
    );
  }
}
