import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/app_button.dart';
import 'package:yum_quick/core/presentation/components/curved_header.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_event.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_state.dart';
import 'package:yum_quick/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:yum_quick/features/orders/presentation/bloc/orders_event.dart';

import '../widgets/checkout_address_card.dart';
import '../widgets/checkout_payment_selector.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();
  int _selectedPaymentMethod = 0;

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
                        _buildSectionTitle('Delivery Address'),
                        const SizedBox(height: 10),
                        CheckoutAddressCard(
                          address: _deliveryAddress,
                          onEdit: () {},
                        ),
                        const SizedBox(height: 20),
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
                        _buildSectionTitle('Payment Method'),
                        const SizedBox(height: 10),
                        CheckoutPaymentSelector(
                          selectedIndex: _selectedPaymentMethod,
                          onSelect: (index) =>
                              setState(() => _selectedPaymentMethod = index),
                        ),
                        const SizedBox(height: 24),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
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
}
