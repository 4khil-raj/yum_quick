import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';
import 'package:yum_quick/features/recipes/domain/entities/recipe_entity.dart';

class HomeRecommendSection extends StatelessWidget {
  final List<RecipeEntity> recipes;
  final bool isLoadingMore;
  final String? paginationError;
  final bool hasMore;
  final ValueChanged<RecipeEntity> onRecipeTap;
  final VoidCallback onRetryMoreTap;

  const HomeRecommendSection({
    super.key,
    required this.recipes,
    required this.isLoadingMore,
    required this.paginationError,
    required this.hasMore,
    required this.onRecipeTap,
    required this.onRetryMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final recommended =
        recipes.length > 4 ? recipes.skip(4).toList() : recipes;
    if (recommended.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recommend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommended.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.05,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final recipe = recommended[index];

              return GestureDetector(
                onTap: () => onRecipeTap(recipe),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: CachedNetworkImage(
                          imageUrl: recipe.image,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppColors.surfaceSoft),
                          errorWidget: (context, url, err) => Container(
                            color: AppColors.surfaceSoft,
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                recipe.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.star,
                                size: 10,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.favorite,
                                size: 10,
                                color: AppColors.primaryOrange,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            PricingCalculator.formatINR(recipe.price),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        if (isLoadingMore) ...[
          const SizedBox(height: 16),
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ] else if (paginationError != null) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: onRetryMoreTap,
              icon: const Icon(
                Icons.refresh,
                size: 16,
                color: AppColors.primaryOrange,
              ),
              label: const Text(
                'Failed to load more. Tap to retry',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ] else if (!hasMore && recommended.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "You've reached the end of recommendations",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
