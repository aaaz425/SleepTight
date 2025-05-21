import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';
import 'package:sleep_tight/features/music/data/models/enums/music_category.dart';
import 'package:sleep_tight/features/music/presentation/widgets/music_category_list.dart';

class MusicScreen extends ConsumerWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9.5),
          child: Text(
            '명상 음악',
            style: AppTextStyles.headlineH3Sb(color: AppColors.font1),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              MusicCategoryList(category: MusicCategory.cozy),
              Divider(thickness: 2, color: AppColors.gray04, height: 2),
              MusicCategoryList(category: MusicCategory.nature),
              Divider(thickness: 2, color: AppColors.gray04, height: 2),
              MusicCategoryList(category: MusicCategory.dreamy),
              Divider(thickness: 2, color: AppColors.gray04, height: 2),
              MusicCategoryList(category: MusicCategory.mystic),
              Divider(thickness: 2, color: AppColors.gray04, height: 2),
              MusicCategoryList(category: MusicCategory.healing),
            ],
          ),
        ),
      ),
    );
  }
}
