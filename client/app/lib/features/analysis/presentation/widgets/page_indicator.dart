import 'package:flutter/material.dart';
import 'package:sleep_tight/core/config/theme/color.dart';
import 'package:sleep_tight/core/config/theme/text_styles.dart';

class PageIndicator extends StatelessWidget {
  final int total;
  final int current;
  final void Function(int index) onChanged;

  const PageIndicator({
    super.key,
    required this.total,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (index) {
          final isSelected = current == index;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${index + 1}',
                style:
                    isSelected
                        ? AppTextStyles.bodyB2Sb(color: AppColors.white)
                        : AppTextStyles.bodyB2Lt(color: AppColors.font2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
