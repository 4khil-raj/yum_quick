import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/rating_badge.dart';

class RecipeInfoChip extends StatelessWidget {
  final String icon;
  final String label;

  const RecipeInfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(icon, width: 14, height: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class RecipeDetailInfoRow extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final int totalTimeMinutes;
  final int caloriesPerServing;

  const RecipeDetailInfoRow({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.totalTimeMinutes,
    required this.caloriesPerServing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBadge(
          rating: rating,
          reviewCount: reviewCount,
          size: 14,
        ),
        const SizedBox(width: 16),
        RecipeInfoChip(
          icon: AppAssets.icClock,
          label: '$totalTimeMinutes mins',
        ),
        const SizedBox(width: 12),
        RecipeInfoChip(
          icon: AppAssets.icKnifeFork,
          label: '$caloriesPerServing kcal',
        ),
      ],
    );
  }
}
