import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:checkpoint/models/game_model.dart';
import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game, this.onTap});

  final GameModel game;
  final VoidCallback? onTap;

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
                padding: const EdgeInsets.fromLTRB(3, 6, 3, 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        game.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: 11, height: 1.15),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.primary,
                          size: 13,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          game.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.mutedText,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
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
