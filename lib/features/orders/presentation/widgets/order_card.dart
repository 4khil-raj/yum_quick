import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/utils/pricing_calculator.dart';
import '../../domain/entities/order_entity.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final Widget? subtitle;
  final Widget? actionButtons;

  const OrderCard({
    super.key,
    required this.order,
    this.subtitle,
    this.actionButtons,
  });

  String _formatDateTime(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[date.month - 1];
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'pm' : 'am';
    return '${date.day} $month ${date.year}, $hour:$minute $ampm';
  }

  Widget _buildStatusBadge(OrderStatus status) {
    final Color bgColor;
    final Color textColor;
    final IconData icon;

    switch (status) {
      case OrderStatus.placed:
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        icon = Icons.access_time_rounded;
      case OrderStatus.preparing:
        bgColor = const Color(0xFFFFF3E0);
        textColor = AppColors.primaryOrange;
        icon = Icons.soup_kitchen_rounded;
      case OrderStatus.onTheWay:
        bgColor = AppColors.chipOrangeTint;
        textColor = AppColors.primaryOrange;
        icon = Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        bgColor = const Color(0xFFE8F5E9);
        textColor = AppColors.success;
        icon = Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        bgColor = const Color(0xFFFFEBEE);
        textColor = AppColors.error;
        icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalItemsCount = order.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.orderId}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDateTime(order.orderDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(order.status),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            subtitle!,
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 12),
          if (order.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No items found in this order',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: item.recipeImage,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 44,
                          height: 44,
                          color: AppColors.surfaceSoft,
                        ),
                        errorWidget: (context, url, err) => Container(
                          width: 44,
                          height: 44,
                          color: AppColors.surfaceSoft,
                          child: const Icon(
                            Icons.fastfood_rounded,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.recipeName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.chipOrangeTint,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  '${item.quantity}x',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                PricingCalculator.formatINR(item.itemUnitPrice),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          if (item.selectedAddOns.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              '+ ${item.selectedAddOns.join(', ')}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      PricingCalculator.formatINR(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalItemsCount ${totalItemsCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Total: ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    PricingCalculator.formatINR(order.total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (order.status == OrderStatus.cancelled &&
              order.cancellationReason != null &&
              order.cancellationReason!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Reason: ${order.cancellationReason}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (actionButtons != null) ...[
            const SizedBox(height: 14),
            actionButtons!,
          ],
        ],
      ),
    );
  }
}
