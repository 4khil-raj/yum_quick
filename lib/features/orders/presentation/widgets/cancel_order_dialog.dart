import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/features/orders/domain/entities/order_entity.dart';

class CancelOrderBottomSheet extends StatefulWidget {
  final OrderEntity order;
  final ValueChanged<String> onConfirmCancel;

  const CancelOrderBottomSheet({
    super.key,
    required this.order,
    required this.onConfirmCancel,
  });

  static void show(
    BuildContext context, {
    required OrderEntity order,
    required ValueChanged<String> onConfirmCancel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return CancelOrderBottomSheet(
          order: order,
          onConfirmCancel: (reason) {
            Navigator.pop(ctx);
            onConfirmCancel(reason);
            OrderCancelledDialog.show(context);
          },
        );
      },
    );
  }

  @override
  State<CancelOrderBottomSheet> createState() => _CancelOrderBottomSheetState();
}

class _CancelOrderBottomSheetState extends State<CancelOrderBottomSheet> {
  String _selectedReason = 'Wait time is too long';
  final List<String> _reasons = [
    'Wait time is too long',
    'Ordered by mistake',
    'Change delivery address',
    'Duplicate order placed',
  ];
  final TextEditingController _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Cancel Order',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please select the reason for cancelling your order.',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.textPrimary.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 20),
            ..._reasons.map((r) {
              final isSel = _selectedReason == r;
              return InkWell(
                onTap: () => setState(() => _selectedReason = r),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        r,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSel
                                ? AppColors.primaryOrange
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: isSel
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
            }),
            const SizedBox(height: 12),
            const Text(
              'Others',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              child: TextField(
                controller: _otherController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Others reason...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 180,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    final finalReason =
                        _selectedReason == 'Others' &&
                                _otherController.text.isNotEmpty
                            ? _otherController.text
                            : _selectedReason;
                    widget.onConfirmCancel(finalReason);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCancelledDialog extends StatelessWidget {
  const OrderCancelledDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (ctx) => const OrderCancelledDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.primaryOrange,
                    size: 32,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryOrange,
                    width: 8,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '¡Order Cancelled!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order has been successfully\ncancelled',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                'If you have any question reach directly to our\ncustomer support',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Back to Orders'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
