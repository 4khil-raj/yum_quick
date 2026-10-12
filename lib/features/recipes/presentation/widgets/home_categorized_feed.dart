import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/empty_state_widget.dart';
import 'package:yum_quick/core/presentation/components/shimmer_loading.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';
import 'package:yum_quick/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_event.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_state.dart';

class HomeCategorizedFeed extends StatelessWidget {
  final SearchState searchState;
  final ValueChanged<RecipeEntity> onRecipeTap;
  final VoidCallback onFilterTap;
  final VoidCallback onResetTap;
  final VoidCallback onRetryTap;

  const HomeCategorizedFeed({
    super.key,
    required this.searchState,
    required this.onRecipeTap,
    required this.onFilterTap,
    required this.onResetTap,
    required this.onRetryTap,
  });

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.relevance:
        return 'Popular';
      case SortOption.ratingHighToLow:
        return 'Top Rated';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.timeFastest:
        return 'Fastest Prep';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (searchState is SearchLoading || searchState is SearchInitial) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.05,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) => const RecipeCardSkeleton(),
        ),
      );
    } else if (searchState is SearchError) {
      final errorState = searchState as SearchError;
      return ErrorRetryWidget(
        message: errorState.message,
        onRetry: onRetryTap,
      );
    } else if (searchState is SearchEmpty) {
      return EmptyStateWidget(
        title: 'No Recipes Found',
        message: 'No recipes match your criteria.',
        buttonText: 'Reset Filters',
        onButtonPressed: onResetTap,
      );
    } else if (searchState is SearchSuccess) {
      final success = searchState as SearchSuccess;
      final recipes = success.results;
      if (recipes.isEmpty) {
        return EmptyStateWidget(
          title: 'No Recipes Found',
          message: 'No recipes match your criteria.',
          buttonText: 'Reset Filters',
          onButtonPressed: onResetTap,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                const Text(
                  'Sort By ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getSortLabel(success.sortOption),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onFilterTap,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recipes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 22),
            itemBuilder: (context, index) {
              return HomeCategorizedFoodCard(
                recipe: recipes[index],
                onTap: () => onRecipeTap(recipes[index]),
              );
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class HomeCategorizedFoodCard extends StatelessWidget {
  final RecipeEntity recipe;
  final VoidCallback onTap;

  const HomeCategorizedFoodCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: CachedNetworkImage(
                imageUrl: recipe.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
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
                errorWidget: (context, url, err) => Container(
                  color: AppColors.surfaceSoft,
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '•',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            recipe.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.star, size: 10, color: Colors.amber),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                PricingCalculator.formatINR(recipe.price),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Text(
            recipe.ingredients.isNotEmpty
                ? recipe.ingredients.take(4).join(', ')
                : '${recipe.cuisine} • ${recipe.difficulty}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
