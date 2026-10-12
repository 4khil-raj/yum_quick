import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';
import 'package:yum_quick/features/recipes/domain/entities/recipe_entity.dart';

class HomeBestSellerSection extends StatelessWidget {
  final List<RecipeEntity> recipes;
  final ValueChanged<RecipeEntity> onRecipeTap;
  final VoidCallback onViewAllTap;

  const HomeBestSellerSection({
    super.key,
    required this.recipes,
    required this.onRecipeTap,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final bestSellers = recipes.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Best Seller',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primaryOrange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: bestSellers.length,
            itemBuilder: (context, index) {
              final recipe = bestSellers[index];

              return GestureDetector(
                onTap: () => onRecipeTap(recipe),
                child: Container(
                  width: 115,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
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
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: recipe.image,
                          width: 115,
                          height: 140,
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
      ],
    );
  }
}
