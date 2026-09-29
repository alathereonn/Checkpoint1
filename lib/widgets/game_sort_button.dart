import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:checkpoint/models/game_sort.dart';
import 'package:flutter/material.dart';

class GameSortButton extends StatelessWidget {
  const GameSortButton({
    super.key,
    required this.selectedSort,
    required this.onChanged,
    required this.scale,
  });

  final GameSort selectedSort;
  final ValueChanged<GameSort> onChanged;
  final double scale;

  double s(double value) => value * scale;

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
        height: s(52),
        padding: EdgeInsets.symmetric(horizontal: s(10)),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(s(14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, color: AppColors.primary, size: s(19)),
            SizedBox(width: s(5)),
            Flexible(
              child: Text(
                selectedSort.label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontSize: s(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, size: s(24)),
          ],
        ),
      ),
    );
  }
}
