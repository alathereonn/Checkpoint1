import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:checkpoint/models/game_model.dart';
import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    this.onTap,
    required this.scale,
  });

  final GameModel game;
  final VoidCallback? onTap;
  final double scale;

  double s(double value) => value * scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 2 / 3,
              child: _GameCover(imageUrl: game.backgroundImage),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(s(3), s(6), s(3), 0),
                child: Text(
                  game.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontSize: s(11), height: 1.15),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(s(3), s(2), s(3), s(3)),
              child: Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: AppColors.primary,
                    size: s(13),
                  ),
                  SizedBox(width: s(2)),
                  Text(
                    game.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                      fontSize: s(10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCover extends StatelessWidget {
  const _GameCover({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const _CoverPlaceholder();
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      cacheWidth: 300,
      errorBuilder: (_, _, _) => const _CoverPlaceholder(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const _CoverPlaceholder();
      },
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceLight,
      child: Center(
        child: const Icon(
          Icons.sports_esports_rounded,
          color: AppColors.primary,
          size: 38,
        ),
      ),
    );
  }
}
