import 'package:flutter/material.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';

class HomeNotificationDrawer extends StatelessWidget {
  const HomeNotificationDrawer({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Notifications',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) {
        return const Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: HomeNotificationDrawer(),
          ),
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.82,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(44),
          bottomLeft: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    AppAssets.icNotification,
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white38, height: 1),
              const SizedBox(height: 8),

              _buildNotificationItem(
                icon: AppAssets.icKnifeFork,
                text: 'We have added a product you might like.',
              ),
              const Divider(color: Colors.white24, height: 1),
              _buildNotificationItem(
                icon: AppAssets.icFavorite,
                text: 'One of your favorite is on promotion.',
              ),
              const Divider(color: Colors.white24, height: 1),
              _buildNotificationItem(
                icon: AppAssets.icOrders,
                text: 'Your order has been delivered',
              ),
              const Divider(color: Colors.white24, height: 1),
              _buildNotificationItem(
                icon: AppAssets.icDelivery,
                text: 'The delivery is on his way',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({required String icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              icon,
              color: AppColors.primaryOrange,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
