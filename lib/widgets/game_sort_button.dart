import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:checkpoint/models/game_sort.dart';
import 'package:flutter/material.dart';

class GameSortButton extends StatelessWidget {
  const GameSortButton({
    super.key,
    required this.selectedSort,
    required this.onChanged,
  });

  final GameSort selectedSort;
  final ValueChanged<GameSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<GameSort>(
      onSelected: onChanged,
      tooltip: 'Sort games',
      itemBuilder: (context) => GameSort.values
          .map(
            (sort) => PopupMenuItem(
              value: sort,
              child: Row(
                children: [
                  Text(sort.label),
                  const Spacer(),
                  if (sort == selectedSort)
                    const Icon(Icons.check_rounded, color: AppColors.primary),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.primary, size: 19),
            const SizedBox(width: 5),
            Text(
              selectedSort.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded),
          ],
        ),
      ),
    );
  }
}
