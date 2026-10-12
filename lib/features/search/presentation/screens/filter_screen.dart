import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/offline_banner.dart';
import 'package:yum_quick/core/utils/category_mapper.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_state.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_bloc.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_event.dart';
import '../widgets/filter_category_bar.dart';
import '../widgets/filter_price_slider.dart';
import '../widgets/filter_rating_selector.dart';
import '../widgets/filter_tag_grid.dart';

class FilterScreen extends StatefulWidget {
  final RecipeCategory? initialCategory;

  const FilterScreen({super.key, this.initialCategory});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late RecipeCategory _selectedCategory;
  int _selectedRating = 4;
  late Set<String> _selectedTags;
  double _priceValue = 500.0;

  static const List<RecipeCategory> _displayCategories = [
    RecipeCategory.snacks,
    RecipeCategory.meal,
    RecipeCategory.vegan,
    RecipeCategory.dessert,
    RecipeCategory.drinks,
  ];

  static const Map<RecipeCategory, List<String>> _categoryTags = {
    RecipeCategory.snacks: [
      'Bruschetta',
      'Spring Rolls',
      'Crepes',
      'Wings',
      'Skewers',
      'Salmon',
      'Mexican',
      'Baked',
      'Appetizer',
    ],
    RecipeCategory.meal: [
      'Sushi',
      'Pizza',
      'Chicken',
      'Curry',
      'Burger',
      'Cheese',
      'Fresh Prawn',
      'Ceviche',
      'Pad Thai',
    ],
    RecipeCategory.vegan: [
      'Bean Burger',
      'Lasagna',
      'Pizza',
      'Mushroom',
      'Risotto',
      'Broccoli',
      'Hummus',
      'Quinoa',
      'Salad',
    ],
    RecipeCategory.dessert: [
      'Crepes',
      'Macarons',
      'Cupcakes',
      'Ice Cream',
      'Flan',
      'Cheesecake',
      'Chocolate',
      'Cakes',
      'Brownie',
    ],
    RecipeCategory.drinks: [
      'Smoothie',
      'Fresh Juice',
      'Iced Tea',
      'Coffee',
      'Cocktail',
      'Soda',
      'Milkshake',
      'Lemonade',
      'Mojito',
    ],
  };

  @override
  void initState() {
    super.initState();
    final searchState = context.read<SearchBloc>().state;

    if (widget.initialCategory != null &&
        widget.initialCategory != RecipeCategory.all) {
      _selectedCategory = widget.initialCategory!;
    } else if (searchState.selectedCategory != RecipeCategory.all) {
      _selectedCategory = searchState.selectedCategory;
    } else {
      _selectedCategory = RecipeCategory.snacks;
    }

    if (searchState.minRating > 0) {
      _selectedRating = searchState.minRating.round();
    } else {
      _selectedRating = 0;
    }

    if (searchState.selectedTags.isNotEmpty) {
      _selectedTags = Set<String>.from(searchState.selectedTags);
    } else {
      _selectedTags = <String>{};
    }

    if (searchState.maxPrice <= 500 && searchState.maxPrice >= 99) {
      _priceValue = searchState.maxPrice.clamp(99.0, 500.0);
    } else {
      _priceValue = 500.0;
    }
  }

  void _onCategorySelected(RecipeCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _selectedTags = <String>{};
    });
  }

  void _onTagToggled(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  void _onReset() {
    setState(() {
      _selectedRating = 0;
      _selectedTags.clear();
      _priceValue = 500.0;
    });
    context.read<SearchBloc>().add(const ClearFiltersReq());
  }

  void _onApply() {
    context.read<SearchBloc>().add(
      UpdateFilterReq(
        category: _selectedCategory,
        sortOption: _selectedRating > 0
            ? SortOption.ratingHighToLow
            : SortOption.relevance,
        minRating: _selectedRating.toDouble(),
        selectedTags: _selectedTags,
        maxPrice: _priceValue,
      ),
    );

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      try {
        context.go('/menu');
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPillList =
        _categoryTags[_selectedCategory] ??
        _categoryTags[RecipeCategory.snacks]!;

    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OfflineBanner(),
            Container(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 16,
                left: 16,
                right: 16,
              ),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      try {
                        context.go('/menu');
                      } catch (_) {}
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 28,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),

                const Expanded(
                  child: Center(
                    child: Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    final count = cartState is CartLoaded
                        ? cartState.totalItemCount
                        : 0;
                    return GestureDetector(
                      onTap: () => context.push('/cart'),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              AppAssets.icCart,
                              width: 18,
                              height: 18,
                              color: AppColors.primaryOrange,
                            ),
                            if (count > 0)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(9),
                    child: Image.asset(
                      AppAssets.icProfile,
                      width: 18,
                      height: 18,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 22,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilterCategoryBar(
                        categories: _displayCategories,
                        selectedCategory: _selectedCategory,
                        onCategorySelected: _onCategorySelected,
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Sort by',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FilterRatingSelector(
                        selectedRating: _selectedRating,
                        onRatingChanged: (rating) {
                          setState(() {
                            _selectedRating = rating;
                          });
                        },
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilterTagGrid(
                        tags: currentPillList,
                        selectedTags: _selectedTags,
                        onTagToggled: _onTagToggled,
                      ),
                      const SizedBox(height: 24),
                      FilterPriceSlider(
                        value: _priceValue,
                        onChanged: (val) {
                          setState(() => _priceValue = val);
                        },
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: SizedBox(
                          width: 175,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _onApply,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(23),
                              ),
                            ),
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Center(
                        child: TextButton(
                          onPressed: _onReset,
                          child: const Text(
                            'Reset All Filters',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
