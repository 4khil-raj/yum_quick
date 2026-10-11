import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/storage/secure_storage_service.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    // 1. Wait for AuthBloc session verification to finish if still resolving
    final authBloc = context.read<AuthBloc>();
    AuthState authState = authBloc.state;
    if (authState is AuthInitial || authState is AuthLoading) {
      try {
        authState = await authBloc.stream
            .firstWhere((s) => s is! AuthInitial && s is! AuthLoading)
            .timeout(const Duration(milliseconds: 1200));
      } catch (_) {
        authState = authBloc.state;
      }
    }

    if (!mounted) return;

    // 2. If authenticated, proceed directly to /home
    if (authState is Authenticated) {
      context.go('/home');
      return;
    }

    // 3. If not authenticated, check if onboarding was already completed
    final hasCompletedOnboarding =
        await SecureStorageService().isOnboardingCompleted();

    if (!mounted) return;

    if (hasCompletedOnboarding) {
      context.go('/welcome');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAssets.logoOrange,
                    width: 240,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
