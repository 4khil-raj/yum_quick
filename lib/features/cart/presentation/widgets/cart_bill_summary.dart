import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';

class CartBillSummary extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double serviceFee;
  final double discount;
  final double total;

  const CartBillSummary({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.serviceFee,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildRow('Item Subtotal', PricingCalculator.formatINR(subtotal)),
          const SizedBox(height: 8),
          _buildRow('Taxes & GST (5%)', PricingCalculator.formatINR(tax)),
          const SizedBox(height: 8),
          _buildRow(
            'Delivery Fee',
            deliveryFee == 0 ? 'FREE' : PricingCalculator.formatINR(deliveryFee),
            valueColor: deliveryFee == 0 ? AppColors.success : null,
          ),
          const SizedBox(height: 8),
          _buildRow(
            'Platform Service Fee',
            PricingCalculator.formatINR(serviceFee),
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildRow(
              'Promo Discount',
              '-${PricingCalculator.formatINR(discount)}',
              valueColor: AppColors.success,
            ),
          ],
          const Divider(height: 24),
          _buildRow(
            'To Pay',
            PricingCalculator.formatINR(total),
            isBold: true,
            valueColor: AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
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
