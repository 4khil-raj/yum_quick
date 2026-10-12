import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/curved_header.dart';
import 'package:yum_quick/core/presentation/components/empty_state_widget.dart';
import 'package:yum_quick/core/presentation/components/food_card.dart';
import 'package:yum_quick/core/utils/app_snackbar.dart';
import 'package:yum_quick/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_event.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
          const CurvedHeader(
            title: Text(
              'My Favorites',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<RecipeBloc, RecipeState>(
              builder: (context, state) {
                if (state is RecipeSuccess) {
                  final favorites = state.recipes
                      .where((r) => state.favoriteIds.contains(r.id))
                      .toList();

                  if (favorites.isEmpty) {
                    return EmptyStateWidget(
                      icon: Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: AppColors.chipOrangeTint,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(22),
                        child: Image.asset(
                          AppAssets.icFavorite,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      title: 'No Favorites Yet',
                      message: 'Tap the heart icon on any recipe to save it to your personal favorites list!',
                      buttonText: 'Explore Menu',
                      onButtonPressed: () => context.go('/menu'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favorites.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 14,
                        ),
                    itemBuilder: (context, index) {
                      final recipe = favorites[index];

                      return FoodCard(
                        recipe: recipe,
                        isFavorite: true,
                        onTap: () =>
                            context.push('/recipe-detail', extra: recipe),
                        onFavoriteTap: () {
                          context.read<RecipeBloc>().add(
                            ToggleFavoriteReq(recipe.id),
                          );
                        },
                        onAddToCart: () {
                          context.read<CartBloc>().add(
                            AddToCartReq(
                              CartItemEntity(
                                recipeId: recipe.id,
                                recipeName: recipe.name,
                                recipeImage: recipe.image,
                                unitPrice: recipe.price,
                                quantity: 1,
                              ),
                            ),
                          );
                          AppSnackBar.showSuccess(
                            context,
                            message: 'Added to cart!',
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrange,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}
