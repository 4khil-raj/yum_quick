import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/offline_banner.dart';
import 'package:yum_quick/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_event.dart';
import 'package:yum_quick/features/orders/domain/entities/order_entity.dart';
import 'package:yum_quick/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:yum_quick/features/orders/presentation/bloc/orders_event.dart';
import 'package:yum_quick/features/orders/presentation/bloc/orders_state.dart';
import '../widgets/cancel_order_dialog.dart';
import '../widgets/order_card.dart';
import '../widgets/order_review_sheet.dart';
import '../widgets/order_tab_selector.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(const LoadOrdersReq());
  }

  void _showCancelDialog(BuildContext context, OrderEntity order) {
    CancelOrderBottomSheet.show(
      context,
      order: order,
      onConfirmCancel: (reason) {
        context.read<OrdersBloc>().add(
          CancelOrderReq(
            orderId: order.orderId,
            reason: reason,
          ),
        );
      },
    );
  }

  void _showReviewDialog(BuildContext context, OrderEntity order) {
    OrderReviewBottomSheet.show(
      context,
      order: order,
      onSubmitReview: (rating, comment) {},
    );
  }

  void _orderAgain(BuildContext context, OrderEntity order) {
    for (final item in order.items) {
      context.read<CartBloc>().add(
        AddToCartReq(
          CartItemEntity(
            recipeId: item.recipeId,
            recipeName: item.recipeName,
            recipeImage: item.recipeImage,
            unitPrice: item.unitPrice,
            quantity: item.quantity,
            selectedAddOns: item.selectedAddOns,
            addOnsPrice: item.addOnsPrice,
          ),
        ),
      );
    }
    context.push('/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          final allOrders = state is OrdersLoaded
              ? state.orders
              : <OrderEntity>[];
          final activeOrders = allOrders.where((o) => o.isActive).toList();
          final completedOrders = allOrders
              .where((o) => o.status == OrderStatus.delivered)
              .toList();
          final cancelledOrders = allOrders
              .where((o) => o.status == OrderStatus.cancelled)
              .toList();

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                const OfflineBanner(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.primaryOrange,
                          size: 32,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'My Orders',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(36),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        OrderTabSelector(
                          selectedIndex: _selectedTab,
                          onTabSelected: (index) =>
                              setState(() => _selectedTab = index),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _selectedTab == 0
                              ? _buildActiveTab(activeOrders)
                              : (_selectedTab == 1
                                    ? _buildCompletedTab(completedOrders)
                                    : _buildCancelledTab(cancelledOrders)),
                        ),
                      ],
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

  Widget _buildActiveTab(List<OrderEntity> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.chipOrangeTint.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(22),
                child: Image.asset(AppAssets.icOrderFood, fit: BoxFit.contain),
              ),
              const SizedBox(height: 24),
              const Text(
                "You don't have any\nactive orders at this time",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryOrange,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        return OrderCard(
          order: order,
          actionButtons: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => _showCancelDialog(context, order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    child: const Text(
                      'Cancel Order',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push('/live-tracking', extra: order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.creamButton,
                      foregroundColor: AppColors.primaryOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    child: const Text(
                      'Track Driver',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedTab(List<OrderEntity> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No completed orders yet.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        return OrderCard(
          order: order,
          actionButtons: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => _showReviewDialog(context, order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    child: const Text(
                      'Leave a review',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => _orderAgain(context, order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.creamButton,
                      foregroundColor: AppColors.primaryOrange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(19),
                      ),
                    ),
                    child: const Text(
                      'Order Again',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCancelledTab(List<OrderEntity> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'No cancelled orders.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        return OrderCard(
          order: order,
          actionButtons: SizedBox(
            height: 38,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _orderAgain(context, order),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.creamButton,
                foregroundColor: AppColors.primaryOrange,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              child: const Text(
                'Order Again',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
