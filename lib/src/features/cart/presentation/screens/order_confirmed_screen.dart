import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/app_button.dart';
import 'package:yum_quick/src/features/orders/state/orders_bloc.dart';
import 'package:yum_quick/src/features/orders/state/orders_state.dart';

class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersState = context.watch<OrdersBloc>().state;
    final latestOrder = ordersState is OrdersLoaded
        ? ordersState.latestPlacedOrder
        : null;
    final orderId = latestOrder?.orderId ?? 'YUM-8492';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Checkmark
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x332E7D32),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(26),
                child: Image.asset(
                  AppAssets.icCheck,
                  color: Colors.white,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Order ID: #$orderId',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your meal is being prepared with love and will be delivered to your doorstep in 25-30 minutes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Track Order',
                icon: Image.asset(
                  AppAssets.icOrders,
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
                onPressed: () => context.go('/orders'),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Back to Home',
                variant: AppButtonVariant.outlined,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
