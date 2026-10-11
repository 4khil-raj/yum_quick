import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/cart/presentation/screens/checkout_screen.dart';
import '../features/cart/presentation/screens/order_confirmed_screen.dart';
import '../features/orders/domain/entities/order_entity.dart';
import '../features/orders/presentation/screens/live_tracking_screen.dart';
import '../features/orders/presentation/screens/orders_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/recipes/domain/entities/recipe_entity.dart';
import '../features/recipes/presentation/screens/best_seller_screen.dart';
import '../features/recipes/presentation/screens/favorites_screen.dart';
import '../features/recipes/presentation/screens/home_screen.dart';
import '../features/recipes/presentation/screens/menu_screen.dart';
import '../features/recipes/presentation/screens/recipe_detail_screen.dart';
import '../features/recipes/presentation/screens/recommendations_screen.dart';
import '../features/search/presentation/screens/filter_screen.dart';
import 'main_navigation_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),

    // Stateful Nested Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Menu
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/menu',
              builder: (context, state) => const MenuScreen(),
              routes: [
                GoRoute(
                  path: 'filter',
                  builder: (context, state) => const FilterScreen(),
                ),
              ],
            ),
          ],
        ),
        // Tab 2: Favorites
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        // Tab 3: Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),
        // Tab 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Push Details & Sub-screens
    GoRoute(path: '/filter', builder: (context, state) => const FilterScreen()),
    GoRoute(
      path: '/recipe-detail',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final recipe = state.extra as RecipeEntity;
        return RecipeDetailScreen(recipe: recipe);
      },
    ),
    GoRoute(
      path: '/best-seller',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BestSellerScreen(),
    ),
    GoRoute(
      path: '/recommendations',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RecommendationsScreen(),
    ),
    GoRoute(
      path: '/cart',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/order-confirmed',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OrderConfirmedScreen(),
    ),
    GoRoute(
      path: '/live-tracking',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final order = state.extra as OrderEntity;
        return LiveTrackingScreen(order: order);
      },
    ),
  ],
);
