import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../utils/pricing_calculator.dart';
import '../../../features/recipes/domain/entities/recipe_entity.dart';
import 'rating_badge.dart';

class FoodCard extends StatelessWidget {
  final RecipeEntity recipe;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCart;
  final double width;

  const FoodCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onAddToCart,
    this.width = 175,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Hero(
                    tag: 'recipe_image_${recipe.id}',
                    child: CachedNetworkImage(
                      imageUrl: recipe.image,
                      height: 125,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 125,
                        color: AppColors.surfaceSoft,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 125,
                        color: AppColors.surfaceSoft,
                        child: const Icon(
                          Icons.restaurant,
                          color: AppColors.textMuted,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                PositionorFav(
                  isFavorite: isFavorite,
                  onFavoriteTap: onFavoriteTap,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingBadge(rating: recipe.rating, size: 12),
                      Row(
                        children: [
                          Image.asset(
                            AppAssets.icClock,
                            width: 12,
                            height: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${recipe.prepTimeMinutes}m',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        PricingCalculator.formatINR(recipe.price),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      if (onAddToCart != null)
                        InkWell(
                          onTap: onAddToCart,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryOrange,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              AppAssets.icPlus,
                              color: Colors.white,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                    ],
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

class PositionorFav extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const PositionorFav({
    super.key,
    required this.isFavorite,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: onFavoriteTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(7),
          child: Image.asset(
            AppAssets.icFavorite,
            color: isFavorite ? AppColors.error : AppColors.textMuted,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
