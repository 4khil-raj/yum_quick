import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';

import '../core/utils/category_mapper.dart';
import '../features/recipes/presentation/bloc/recipe_bloc.dart';
import '../features/recipes/presentation/bloc/recipe_event.dart';

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  void _onItemTapped(BuildContext context, int index) {
    if (index == 0) {
      context.read<RecipeBloc>().add(
        const ChangeCategoryReq(RecipeCategory.all),
      );
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primaryOrange,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  currentIndex: currentIndex,
                  assetPath: AppAssets.navHome,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  currentIndex: currentIndex,
                  assetPath: AppAssets.navMenu,
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  currentIndex: currentIndex,
                  assetPath: AppAssets.navFavorite,
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  currentIndex: currentIndex,
                  assetPath: AppAssets.navOrders,
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  currentIndex: currentIndex,
                  assetPath: AppAssets.navSupport,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    String? assetPath,
    Widget? icon,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(context, index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.80,
              child:
                  icon ??
                  Image.asset(
                    assetPath!,
                    width: 28,
                    height: 28,
                    color: Colors.white,
                    fit: BoxFit.contain,
                  ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
