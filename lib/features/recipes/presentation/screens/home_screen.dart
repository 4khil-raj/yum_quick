import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/empty_state_widget.dart';
import 'package:yum_quick/core/presentation/components/offline_banner.dart';
import 'package:yum_quick/core/presentation/components/shimmer_loading.dart';
import 'package:yum_quick/core/utils/category_mapper.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_state.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:yum_quick/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_bloc.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_event.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_state.dart';

import '../widgets/home_best_seller_section.dart';
import '../widgets/home_categories_bar.dart';
import '../widgets/home_categorized_feed.dart';
import '../widgets/home_notification_drawer.dart';
import '../widgets/home_promo_carousel.dart';
import '../widgets/home_recommend_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  late final PageController _promoPageController;
  int _currentPromoPage = 0;
  Timer? _promoAutoPlayTimer;

  final List<Map<String, dynamic>> _promoBanners = [
    {
      'title': 'Experience our\ndelicious new dish',
      'discount': '30% OFF',
      'image': AppAssets.imgOnboardingPizza,
      'color': AppColors.primaryOrange,
    },
    {
      'title': 'Sweeten your day with\nfresh baked treats',
      'discount': '25% OFF',
      'image': AppAssets.imgOnboardingBrownie,
      'color': const Color(0xFFE65100),
    },
    {
      'title': 'Morning kickstart with\npremium hot brews',
      'discount': 'BUY 1 GET 1',
      'image': AppAssets.imgOnboardingCoffee,
      'color': const Color(0xFFD84315),
    },
    {
      'title': 'Chef Special Gourmet\nWeekend Delight',
      'discount': '40% OFF',
      'image': AppAssets.imgOnboardingPizza,
      'color': AppColors.primaryOrange,
    },
    {
      'title': 'Free Delivery on\nyour first 3 orders',
      'discount': 'CODE: YUMFREE',
      'image': AppAssets.imgOnboardingBrownie,
      'color': const Color(0xFFEF6C00),
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'label': 'Snacks',
      'icon': AppAssets.icSnacks,
      'cat': RecipeCategory.snacks,
    },
    {
      'label': 'Meal',
      'icon': AppAssets.icKnifeFork,
      'cat': RecipeCategory.meal,
    },
    {
      'label': 'Vegan',
      'icon': AppAssets.icVegetables,
      'cat': RecipeCategory.vegan,
    },
    {
      'label': 'Dessert',
      'icon': AppAssets.icDesserts,
      'cat': RecipeCategory.dessert,
    },
    {
      'label': 'Drinks',
      'icon': AppAssets.icBeverages,
      'cat': RecipeCategory.drinks,
    },
  ];

  @override
  void initState() {
    super.initState();
    _promoPageController = PageController();
    _startPromoAutoPlay();
    _scrollController.addListener(_onScroll);
    final searchBloc = context.read<SearchBloc>();
    if (searchBloc.state is SearchInitial) {
      searchBloc.add(const SearchRecipesReq(''));
    }
  }

  void _startPromoAutoPlay() {
    _promoAutoPlayTimer?.cancel();
    _promoAutoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_promoPageController.hasClients) {
        final nextPage = (_currentPromoPage + 1) % _promoBanners.length;
        _promoPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 250) {
      final recipeState = context.read<RecipeBloc>().state;
      if (recipeState is RecipeSuccess &&
          recipeState.hasMore &&
          !recipeState.isLoadingMore) {
        context.read<RecipeBloc>().add(const LoadMoreRecipesReq());
      }
    }
  }

  @override
  void dispose() {
    _promoAutoPlayTimer?.cancel();
    _promoPageController.dispose();
    _debounceTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      context.read<SearchBloc>().add(SearchRecipesReq(query));
    });
  }

  void _onCategorySelected(RecipeCategory cat) {
    final searchBloc = context.read<SearchBloc>();
    final currentCat = searchBloc.state.selectedCategory;
    final newCat = (currentCat == cat) ? RecipeCategory.all : cat;

    searchBloc.add(
      UpdateFilterReq(
        category: newCat,
        selectedTags: const {},
      ),
    );
    context.read<RecipeBloc>().add(ChangeCategoryReq(newCat));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, searchState) {
          final recipeState = context.watch<RecipeBloc>().state;
          final isOffline =
              recipeState is RecipeSuccess && recipeState.isOfflineFallback;
          final currentCat = searchState.selectedCategory;
          final isCategorized = currentCat != RecipeCategory.all;
          final isSearching = _searchController.text.trim().isNotEmpty;
          final showCategorizedOrSearch = isCategorized || isSearching;

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                OfflineBanner(isOffline: isOffline),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 8,
                    bottom: isCategorized ? 12 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      onChanged: _onSearchChanged,
                                      decoration: const InputDecoration(
                                        hintText: 'Search',
                                        hintStyle: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: Image.asset(
                                          AppAssets.icClose,
                                          width: 14,
                                          height: 14,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: () => context.push('/menu/filter'),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryOrange,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.tune_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          BlocBuilder<CartBloc, CartState>(
                            builder: (context, cartState) {
                              final count = cartState is CartLoaded
                                  ? cartState.totalItemCount
                                  : 0;

                              return _buildCircleHeaderAction(
                                icon: Image.asset(
                                  AppAssets.icCart,
                                  width: 21,
                                  height: 21,
                                  color: AppColors.primaryOrange,
                                ),
                                badgeCount: count,
                                onTap: () => context.push('/cart'),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildCircleHeaderAction(
                            icon: Image.asset(
                              AppAssets.icNotification,
                              width: 21,
                              height: 21,
                              color: AppColors.primaryOrange,
                            ),
                            onTap: () => HomeNotificationDrawer.show(context),
                          ),
                          const SizedBox(width: 8),
                          _buildCircleHeaderAction(
                            icon: Image.asset(
                              AppAssets.icProfile,
                              width: 21,
                              height: 21,
                              color: AppColors.primaryOrange,
                            ),
                            onTap: () => context.push('/profile'),
                          ),
                        ],
                      ),
                      if (!isCategorized && !isSearching) ...[
                        const SizedBox(height: 18),
                        const Text(
                          'Good Morning',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Rise And Shine! It's Breakfast Time",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryOrange,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCategorized)
                  HomeOrangeCategoriesBar(
                    currentCategory: currentCat,
                    categories: _categories,
                    onCategorySelected: _onCategorySelected,
                  ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: isCategorized
                          ? BorderRadius.zero
                          : const BorderRadius.vertical(top: Radius.circular(36)),
                    ),
                    child: ClipRRect(
                      borderRadius: isCategorized
                          ? BorderRadius.zero
                          : const BorderRadius.vertical(top: Radius.circular(36)),
                      child: RefreshIndicator(
                        color: AppColors.primaryOrange,
                        onRefresh: () async {
                          context.read<RecipeBloc>().add(
                            const RefreshRecipesReq(),
                          );
                          context.read<SearchBloc>().add(
                            SearchRecipesReq(_searchController.text),
                          );
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 20, bottom: 80),
                          child: showCategorizedOrSearch
                              ? HomeCategorizedFeed(
                                  searchState: searchState,
                                  onRecipeTap: (recipe) => context.push(
                                    '/recipe-detail',
                                    extra: recipe,
                                  ),
                                  onFilterTap: () => context.push('/menu/filter'),
                                  onResetTap: () {
                                    _searchController.clear();
                                    context.read<SearchBloc>().add(
                                      const ClearFiltersReq(),
                                    );
                                    context.read<RecipeBloc>().add(
                                      const ChangeCategoryReq(
                                        RecipeCategory.all,
                                      ),
                                    );
                                  },
                                  onRetryTap: () {
                                    context.read<SearchBloc>().add(
                                      SearchRecipesReq(_searchController.text),
                                    );
                                  },
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HomeDefaultCategoriesRow(
                                      categories: _categories,
                                      onCategorySelected: _onCategorySelected,
                                    ),
                                    const SizedBox(height: 20),
                                    if (recipeState is RecipeLoading) ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: 4,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 1.05,
                                                crossAxisSpacing: 12,
                                                mainAxisSpacing: 12,
                                              ),
                                          itemBuilder: (context, index) =>
                                              const RecipeCardSkeleton(),
                                        ),
                                      ),
                                    ] else if (recipeState is RecipeError) ...[
                                      ErrorRetryWidget(
                                        message: recipeState.message,
                                        onRetry: () {
                                          context.read<RecipeBloc>().add(
                                            const FetchRecipesReq(),
                                          );
                                        },
                                      ),
                                    ] else if (recipeState is RecipeEmpty) ...[
                                      EmptyStateWidget(
                                        title: 'No Recipes Found',
                                        message:
                                            'No recipes match this category.',
                                        buttonText: 'View All',
                                        onButtonPressed: () {
                                          _onCategorySelected(
                                            RecipeCategory.all,
                                          );
                                        },
                                      ),
                                    ] else if (recipeState is RecipeSuccess) ...[
                                      HomeBestSellerSection(
                                        recipes: recipeState.recipes,
                                        onRecipeTap: (recipe) => context.push(
                                          '/recipe-detail',
                                          extra: recipe,
                                        ),
                                        onViewAllTap: () =>
                                            context.push('/best-seller'),
                                      ),
                                      const SizedBox(height: 24),
                                      HomePromoCarousel(
                                        controller: _promoPageController,
                                        currentPage: _currentPromoPage,
                                        onPageChanged: (index) {
                                          setState(() {
                                            _currentPromoPage = index;
                                          });
                                        },
                                        banners: _promoBanners,
                                        onBannerTap: () =>
                                            context.push('/menu'),
                                      ),
                                      const SizedBox(height: 24),
                                      HomeRecommendSection(
                                        recipes: recipeState.recipes,
                                        isLoadingMore:
                                            recipeState.isLoadingMore,
                                        paginationError:
                                            recipeState.paginationError,
                                        hasMore: recipeState.hasMore,
                                        onRecipeTap: (recipe) => context.push(
                                          '/recipe-detail',
                                          extra: recipe,
                                        ),
                                        onRetryMoreTap: () {
                                          context.read<RecipeBloc>().add(
                                            const LoadMoreRecipesReq(),
                                          );
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCircleHeaderAction({
    required Widget icon,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
        child: Center(
          child: badgeCount > 0
              ? Badge(
                  label: Text('$badgeCount'),
                  backgroundColor: AppColors.primaryOrange,
                  textColor: Colors.white,
                  child: icon,
                )
              : icon,
        ),
      ),
    );
  }
}
