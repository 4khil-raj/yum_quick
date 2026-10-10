import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';
import 'package:yum_quick/src/features/cart/state/cart_bloc.dart';
import 'package:yum_quick/src/features/cart/state/cart_state.dart';
import 'package:yum_quick/src/features/search/state/search_bloc.dart';
import 'package:yum_quick/src/features/search/state/search_event.dart';

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
  double _priceValue = 10.0;

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

  static const Map<RecipeCategory, Set<String>> _defaultFigmaTags = {
    RecipeCategory.snacks: {'Skewers', 'Salmon'},
    RecipeCategory.meal: {'Sushi', 'Curry'},
    RecipeCategory.vegan: {'Mushroom', 'Risotto'},
    RecipeCategory.dessert: {'Cupcakes', 'Chocolate'},
    RecipeCategory.drinks: {'Fresh Juice', 'Coffee'},
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
    } else if (_selectedCategory == RecipeCategory.vegan) {
      _selectedRating = 3;
    } else {
      _selectedRating = 4;
    }

    if (searchState.selectedTags.isNotEmpty) {
      _selectedTags = Set<String>.from(searchState.selectedTags);
    } else {
      _selectedTags = Set<String>.from(
        _defaultFigmaTags[_selectedCategory] ?? {},
      );
    }

    if (searchState.maxPrice < 500) {
      _priceValue = searchState.maxPrice.clamp(1.0, 100.0);
    } else if (_selectedCategory == RecipeCategory.meal ||
        _selectedCategory == RecipeCategory.dessert) {
      _priceValue = 50.0;
    } else {
      _priceValue = 10.0;
    }
  }

  void _onCategorySelected(RecipeCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _selectedTags = Set<String>.from(_defaultFigmaTags[category] ?? {});
      if (category == RecipeCategory.vegan) {
        _selectedRating = 3;
        _priceValue = 10.0;
      } else if (category == RecipeCategory.meal) {
        _selectedRating = 4;
        _priceValue = 50.0;
      } else if (category == RecipeCategory.dessert) {
        _selectedRating = 4;
        _priceValue = 50.0;
      } else if (category == RecipeCategory.snacks) {
        _selectedRating = 4;
        _priceValue = 10.0;
      }
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
    final topPadding = MediaQuery.of(context).padding.top;
    final currentPillList =
        _categoryTags[_selectedCategory] ??
        _categoryTags[RecipeCategory.snacks]!;

    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: Column(
        children: [
          // Yellow Header Bar matching Figma
          Container(
            padding: EdgeInsets.only(
              top: topPadding + 8,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                // Back Chevron Button in Orange
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

                // Center Bold Title
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

                // Cart Circular Button
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

                // Profile Circular Button
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

          // White Card Body with Top Rounded Radius
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
                      // Section 1: Categories Title
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Row of 5 Circular Categories
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _displayCategories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () => _onCategorySelected(cat),
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryYellow
                                        : const Color(0xFFFDEECF),
                                    shape: BoxShape.circle,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primaryYellow
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  padding: const EdgeInsets.all(13),
                                  child: Image.asset(
                                    cat.iconPath,
                                    color: AppColors.primaryOrange,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      // Section 2: Sort by
                      const Text(
                        'Sort by',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // "Top Rated" + 5 Interactive Stars
                      Row(
                        children: [
                          const Text(
                            'Top Rated',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Row(
                            children: List.generate(5, (index) {
                              final starNum = index + 1;
                              final isFilled = starNum <= _selectedRating;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedRating =
                                        (_selectedRating == starNum)
                                        ? 0
                                        : starNum;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Icon(
                                    isFilled
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 20,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Section 3: Subcategory Tags (labeled "Categories")
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3x3 Grid of Subcategory Pills
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentPillList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 2.7,
                            ),
                        itemBuilder: (context, index) {
                          final tag = currentPillList[index];
                          final isSelected = _selectedTags.contains(tag);

                          return GestureDetector(
                            onTap: () => _onTagToggled(tag),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryOrange
                                    : const Color(0xFFFDEECF),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                tag,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Section 4: Price Title in Orange
                      const Text(
                        'Price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Slider with Orange active track & thumb
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primaryOrange,
                          inactiveTrackColor: const Color(0xFFE5E5E5),
                          thumbColor: AppColors.primaryOrange,
                          trackHeight: 5.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8.5,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16.0,
                          ),
                          overlayColor: AppColors.primaryOrange.withValues(
                            alpha: 0.15,
                          ),
                        ),
                        child: Slider(
                          value: _priceValue,
                          min: 1.0,
                          max: 100.0,
                          onChanged: (val) {
                            setState(() => _priceValue = val);
                          },
                        ),
                      ),

                      // Price Scale Labels
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$1',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              '\$10',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              '\$50',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                            Text(
                              '\$100 >',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Section 5: "Apply" Orange Pill Button
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

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
