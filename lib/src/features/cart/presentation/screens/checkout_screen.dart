import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/app_button.dart';
import 'package:yum_quick/src/core/presentation/components/curved_header.dart';
import 'package:yum_quick/src/core/utils/pricing_calculator.dart';
import 'package:yum_quick/src/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:yum_quick/src/features/orders/presentation/bloc/orders_event.dart';
import 'package:yum_quick/src/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/src/features/cart/presentation/bloc/cart_event.dart';
import 'package:yum_quick/src/features/cart/presentation/bloc/cart_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();
  int _selectedPaymentMethod = 0; // 0: UPI, 1: Card, 2: COD

  final String _deliveryAddress =
      'Flat 402, Sunshine Apartments, 12th Cross Road, Indiranagar';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onPlaceOrder(CartLoaded cartState) {
    context.read<OrdersBloc>().add(
      PlaceOrderReq(
        items: cartState.items,
        subtotal: cartState.subtotal,
        tax: cartState.tax,
        deliveryFee: cartState.deliveryFee,
        total: cartState.total,
        deliveryAddress: _deliveryAddress,
        deliveryNotes: _notesController.text.trim(),
      ),
    );

    // Clear cart once order is placed
    context.read<CartBloc>().add(const ClearCartReq());

    context.go('/order-confirmed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is! CartLoaded) {
            return const Center(child: Text('Your cart is empty.'));
          }
          final cartState = state;

          return SafeArea(
            top: false,
            child: Column(
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
                title: const Text(
                  'Checkout & Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
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
                      // Delivery Address
                      _buildSectionTitle('Delivery Address'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.chipOrangeTint,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                AppAssets.icLocation,
                                width: 18,
                                height: 18,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Home',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _deliveryAddress,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Image.asset(
                                AppAssets.icEdit,
                                width: 18,
                                height: 18,
                                color: AppColors.primaryOrange,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Delivery Instructions
                      _buildSectionTitle('Delivery Notes'),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText:
                              'e.g. Leave with security, ring doorbell...',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              AppAssets.icInfo,
                              width: 18,
                              height: 18,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Payment Method
                      _buildSectionTitle('Payment Method'),
                      const SizedBox(height: 10),
                      _buildPaymentOption(
                        index: 0,
                        title: 'UPI / Instant Pay',
                        subtitle: 'Google Pay, PhonePe, Paytm',
                        icon: AppAssets.icPayment,
                      ),
                      _buildPaymentOption(
                        index: 1,
                        title: 'Credit / Debit Card',
                        subtitle: 'Visa, MasterCard, RuPay',
                        icon: AppAssets.icPayment,
                      ),
                      _buildPaymentOption(
                        index: 2,
                        title: 'Cash on Delivery',
                        subtitle: 'Pay cash upon delivery',
                        icon: AppAssets.icDelivery,
                      ),
                      const SizedBox(height: 24),

                      // Items Preview
                      _buildSectionTitle(
                        'Order Summary (${cartState.totalItemCount} ${cartState.totalItemCount == 1 ? 'item' : 'items'})',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: cartState.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item.quantity} × ${item.recipeName}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    PricingCalculator.formatINR(
                                      item.totalPrice,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Total & Place Order Button
                      AppButton(
                        text:
                            'Place Order • ${PricingCalculator.formatINR(cartState.total)}',
                        onPressed: () => _onPlaceOrder(cartState),
                      ),
                      const SizedBox(height: 24),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required String title,
    required String subtitle,
    required String icon,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.chipOrangeTint
                    : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                icon,
                width: 20,
                height: 20,
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: isSelected
                  ? Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
