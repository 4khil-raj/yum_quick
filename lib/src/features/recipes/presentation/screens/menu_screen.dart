import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/curved_header.dart';
import 'package:yum_quick/src/core/presentation/components/empty_state_widget.dart';
import 'package:yum_quick/src/core/presentation/components/food_card.dart';
import 'package:yum_quick/src/core/presentation/components/shimmer_loading.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';
import 'package:yum_quick/src/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/src/features/cart/state/cart_bloc.dart';
import 'package:yum_quick/src/features/cart/state/cart_event.dart';
import 'package:yum_quick/src/features/search/state/search_bloc.dart';
import 'package:yum_quick/src/features/search/state/search_event.dart';
import 'package:yum_quick/src/features/search/state/search_state.dart';
import 'package:yum_quick/src/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_bloc.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_event.dart';
import 'package:yum_quick/src/features/recipes/state/recipe_state.dart';

class MenuScreen extends StatefulWidget {
  final RecipeCategory? initialCategory;

  const MenuScreen({super.key, this.initialCategory});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Fetch initial search results
    context.read<SearchBloc>().add(const SearchRecipesReq(''));
    if (widget.initialCategory != null) {
      context.read<SearchBloc>().add(
        UpdateFilterReq(category: widget.initialCategory),
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      context.read<SearchBloc>().add(SearchRecipesReq(query));
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return BlocBuilder<SearchBloc, SearchState>(
          builder: (context, searchState) {
            var selectedSort = searchState.sortOption;
            var maxPrice = searchState.maxPrice;
            var selectedCat = searchState.selectedCategory;

            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters & Sorting',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<SearchBloc>().add(
                                const ClearFiltersReq(),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Reset',
                              style: TextStyle(color: AppColors.primaryOrange),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Sort options
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SortOption.values.map((sort) {
                          final isSelected = selectedSort == sort;
                          return ChoiceChip(
                            label: Text(sort.label),
                            selected: isSelected,
                            selectedColor: AppColors.chipOrangeTint,
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() => selectedSort = sort);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Price range slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Maximum Price',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '₹${maxPrice.toInt()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: maxPrice,
                        min: 99.0,
                        max: 500.0,
                        divisions: 8,
                        activeColor: AppColors.primaryOrange,
                        inactiveColor: AppColors.chipOrangeTint,
                        onChanged: (val) {
                          setModalState(() => maxPrice = val);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Apply button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<SearchBloc>().add(
                              UpdateFilterReq(
                                category: selectedCat,
                                sortOption: selectedSort,
                                maxPrice: maxPrice,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Header with search bar and filter button
          CurvedHeader(
            title: const Text(
              'Explore Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Image.asset(
                          AppAssets.icSearchPlus,
                          width: 18,
                          height: 18,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: const InputDecoration(
                              hintText: 'Search pizza, pasta, salad...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: Image.asset(
                              AppAssets.icClose,
                              width: 16,
                              height: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showFilterBottomSheet(context),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      AppAssets.icSettings,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Pills Filter Bar
          _buildCategoryFilterBar(context),

          // Results Grid
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, searchState) {
                final favIds = context.select<RecipeBloc, Set<int>>(
                  (b) => b.state is RecipeSuccess
                      ? (b.state as RecipeSuccess).favoriteIds
                      : {},
                );

                if (searchState is SearchLoading) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      itemCount: 6,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                          ),
                      itemBuilder: (context, index) =>
                          const RecipeCardSkeleton(),
                    ),
                  );
                } else if (searchState is SearchEmpty) {
                  return EmptyStateWidget(
                    title: 'No Matching Dishes',
                    message: searchState.query.isNotEmpty
                        ? 'No recipes found for "${searchState.query}". Try a different keyword or reset filters.'
                        : 'No recipes found for the selected category.',
                    buttonText: 'Reset Filters',
                    onButtonPressed: () {
                      _searchController.clear();
                      context.read<SearchBloc>().add(const ClearFiltersReq());
                      context.read<SearchBloc>().add(
                        const SearchRecipesReq(''),
                      );
                    },
                  );
                } else if (searchState is SearchError) {
                  return Center(
                    child: Text(
                      searchState.message,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                } else if (searchState is SearchSuccess) {
                  return RefreshIndicator(
                    color: AppColors.primaryOrange,
                    onRefresh: () async {
                      context.read<SearchBloc>().add(
                        SearchRecipesReq(_searchController.text),
                      );
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: searchState.results.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                          ),
                      itemBuilder: (context, index) {
                        final recipe = searchState.results[index];
                        final isFav = favIds.contains(recipe.id);

                        return FoodCard(
                          recipe: recipe,
                          isFavorite: isFav,
                          onTap: () =>
                              context.push('/recipe-detail', extra: recipe),
                          onFavoriteTap: () {
                            context.read<RecipeBloc>().add(
                              ToggleFavoriteReq(recipe.id),
                            );
                          },
                          onAddToCart: () {
                            _quickAddToCart(context, recipe);
                          },
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterBar(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        final currentCat = state.selectedCategory;

        return Container(
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: RecipeCategory.values.length,
            itemBuilder: (context, index) {
              final cat = RecipeCategory.values[index];
              final isSelected = currentCat == cat;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat.label),
                  selected: isSelected,
                  selectedColor: AppColors.chipOrangeTint,
                  backgroundColor: AppColors.surfaceSoft,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryOrange
                        : AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.border,
                    ),
                  ),
                  onSelected: (selected) {
                    context.read<SearchBloc>().add(
                      UpdateFilterReq(
                        category: selected ? cat : RecipeCategory.all,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _quickAddToCart(BuildContext context, RecipeEntity recipe) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${recipe.name} to cart!'),
        backgroundColor: AppColors.primaryOrange,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
