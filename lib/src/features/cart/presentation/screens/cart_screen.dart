import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/app_button.dart';
import 'package:yum_quick/src/core/presentation/components/curved_header.dart';
import 'package:yum_quick/src/core/presentation/components/empty_state_widget.dart';
import 'package:yum_quick/src/core/presentation/components/quantity_control.dart';
import 'package:yum_quick/src/core/utils/pricing_calculator.dart';
import 'package:yum_quick/src/features/cart/domain/entities/cart_item_entity.dart';
import 'package:yum_quick/src/features/cart/state/cart_bloc.dart';
import 'package:yum_quick/src/features/cart/state/cart_event.dart';
import 'package:yum_quick/src/features/cart/state/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _onApplyPromo() {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    context.read<CartBloc>().add(ApplyPromoCodeReq(code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied promo code: $code'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartLoaded && state.recentlyRemovedItem != null) {
            final removed = state.recentlyRemovedItem!;
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed ${removed.recipeName}'),
                backgroundColor: AppColors.textPrimary,
                action: SnackBarAction(
                  label: 'UNDO',
                  textColor: AppColors.primaryYellow,
                  onPressed: () {
                    context.read<CartBloc>().add(
                      const RestoreRemovedCartItemReq(),
                    );
                  },
                ),
              ),
            );
          } else if (state is CartEmpty && state.recentlyRemovedItem != null) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Removed ${state.recentlyRemovedItem!.recipeName}',
                ),
                backgroundColor: AppColors.textPrimary,
                action: SnackBarAction(
                  label: 'UNDO',
                  textColor: AppColors.primaryYellow,
                  onPressed: () {
                    context.read<CartBloc>().add(
                      const RestoreRemovedCartItemReq(),
                    );
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartEmpty) {
            return Column(
              children: [
                const CurvedHeader(
                  title: Text(
                    'My Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: EmptyStateWidget(
                    icon: Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: AppColors.chipOrangeTint,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Image.asset(
                        AppAssets.icCart,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    title: 'Your Cart is Empty',
                    message: 'Looks like you have not added anything to your cart yet. Explore our delicious menu!',
                    buttonText: 'Explore Menu',
                    onButtonPressed: () => context.go('/menu'),
                  ),
                ),
              ],
            );
          }

          if (state is CartLoaded) {
            return Column(
              children: [
                CurvedHeader(
                  leading: IconButton(
                    icon: Image.asset(
                      AppAssets.icArrowBack,
                      width: 20,
                      height: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    'My Cart (${state.totalItemCount} items)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Image.asset(
                        AppAssets.icDelete,
                        width: 20,
                        height: 20,
                        color: AppColors.error,
                      ),
                      onPressed: () {
                        context.read<CartBloc>().add(const ClearCartReq());
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cart Items List
                        ...state.items.map(
                          (item) => _buildCartItemCard(context, item),
                        ),

                        const SizedBox(height: 16),

                        // Promo code box
                        _buildPromoCodeSection(context, state),

                        const SizedBox(height: 20),

                        // Bill Details Breakdown
                        _buildBillDetails(state),

                        const SizedBox(height: 24),

                        // Checkout Button
                        AppButton(
                          text:
                              'Proceed to Checkout • ${PricingCalculator.formatINR(state.total)}',
                          onPressed: () => context.push('/checkout'),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItemEntity item) {
    return Dismissible(
      key: Key('cart_item_${item.recipeId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Image.asset(
          AppAssets.icDelete,
          width: 24,
          height: 24,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        context.read<CartBloc>().add(RemoveFromCartReq(item.recipeId));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: item.recipeImage,
                width: 74,
                height: 74,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: 74,
                  height: 74,
                  color: AppColors.surfaceSoft,
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.recipeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.selectedAddOns.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.selectedAddOns.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    PricingCalculator.formatINR(item.totalPrice),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
            QuantityControl(
              quantity: item.quantity,
              min: 0,
              onQuantityChanged: (q) {
                context.read<CartBloc>().add(
                  UpdateCartQuantityReq(recipeId: item.recipeId, quantity: q),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Image.asset(
            AppAssets.icDiscount,
            width: 22,
            height: 22,
            color: AppColors.primaryOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _promoController,
              decoration: InputDecoration(
                hintText: state.promoCode != null
                    ? state.promoCode!
                    : 'Promo Code (e.g. YUM20)',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _onApplyPromo,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              minimumSize: const Size(70, 36),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Apply',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetails(CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildBillRow(
            'Item Subtotal',
            PricingCalculator.formatINR(state.subtotal),
          ),
          const SizedBox(height: 8),
          _buildBillRow(
            'Taxes & GST (5%)',
            PricingCalculator.formatINR(state.tax),
          ),
          const SizedBox(height: 8),
          _buildBillRow(
            'Delivery Fee',
            state.deliveryFee == 0
                ? 'FREE'
                : PricingCalculator.formatINR(state.deliveryFee),
            valueColor: state.deliveryFee == 0 ? AppColors.success : null,
          ),
          const SizedBox(height: 8),
          _buildBillRow(
            'Platform Service Fee',
            PricingCalculator.formatINR(state.serviceFee),
          ),
          if (state.discount > 0) ...[
            const SizedBox(height: 8),
            _buildBillRow(
              'Promo Discount',
              '-${PricingCalculator.formatINR(state.discount)}',
              valueColor: AppColors.success,
            ),
          ],
          const Divider(height: 24),
          _buildBillRow(
            'To Pay',
            PricingCalculator.formatINR(state.total),
            isBold: true,
            valueColor: AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
