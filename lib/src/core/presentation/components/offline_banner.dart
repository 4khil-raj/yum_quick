import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../connectivity/connectivity_service.dart';
import '../../constants/app_colors.dart';
import '../../../features/recipes/presentation/bloc/recipe_bloc.dart';
import '../../../features/recipes/presentation/bloc/recipe_state.dart';

class OfflineBanner extends StatefulWidget {
  final bool? isOffline;

  const OfflineBanner({super.key, this.isOffline});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription<bool>? _connectivitySub;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  void _initConnectivity() {
    try {
      final conn = ConnectivityServiceImpl();
      conn.isConnected.then((connected) {
        if (mounted) setState(() => _isConnected = connected);
      }).catchError((_) {});

      _connectivitySub = conn.onConnectivityChanged.listen((connected) {
        if (mounted) setState(() => _isConnected = connected);
      }, onError: (_) {});
    } catch (_) {
      _isConnected = true;
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOffline != null) {
      if (!widget.isOffline!) return const SizedBox.shrink();
      return _buildBanner();
    }

    bool isOfflineFallback = false;
    try {
      final recipeState = context.watch<RecipeBloc>().state;
      if (recipeState is RecipeSuccess && recipeState.isOfflineFallback) {
        isOfflineFallback = true;
      }
    } catch (_) {}

    final showOffline = isOfflineFallback || !_isConnected;
    if (!showOffline) return const SizedBox.shrink();

    return _buildBanner();
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      color: AppColors.warning,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'You are offline. Showing cached recipes.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
