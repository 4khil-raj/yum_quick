import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/app_button.dart';
import 'package:yum_quick/core/presentation/components/curved_header.dart';
import 'package:yum_quick/core/presentation/components/empty_state_widget.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_event.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_state.dart';
import '../widgets/cart_bill_summary.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_promo_section.dart';

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
            return SafeArea(
              top: false,
              child: Column(
              children: [
                CurvedHeader(
                  leading: IconButton(
                    icon: Image.asset(
                      AppAssets.icArrowBack,
                      width: 28,
                      height: 28,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  title: const Text(
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
            ),
          );
        }

          if (state is CartLoaded) {
            return SafeArea(
              top: false,
              child: Column(
              children: [
                CurvedHeader(
                  leading: IconButton(
                    icon: Image.asset(
                      AppAssets.icArrowBack,
                      width: 28,
                      height: 28,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  title: Text(
                    'My Cart (${state.totalItemCount} ${state.totalItemCount == 1 ? 'item' : 'items'})',
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
                        width: 28,
                        height: 28,
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
                        ...state.items.map(
                          (item) => CartItemCard(
                            item: item,
                            onQuantityChanged: (q) {
                              context.read<CartBloc>().add(
                                UpdateCartQuantityReq(
                                  recipeId: item.recipeId,
                                  quantity: q,
                                ),
                              );
                            },
                            onDismissed: () {
                              context.read<CartBloc>().add(
                                RemoveFromCartReq(item.recipeId),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        CartPromoSection(
                          controller: _promoController,
                          appliedPromoCode: state.promoCode,
                          onApply: _onApplyPromo,
                        ),
                        const SizedBox(height: 20),
                        CartBillSummary(
                          subtotal: state.subtotal,
                          tax: state.tax,
                          deliveryFee: state.deliveryFee,
                          serviceFee: state.serviceFee,
                          discount: state.discount,
                          total: state.total,
                        ),
                        const SizedBox(height: 24),
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
            ),
          );
        }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          );
        },
      ),
    );
  }
}
