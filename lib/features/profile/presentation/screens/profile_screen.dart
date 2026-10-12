import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/core/constants/app_assets.dart';
import 'package:yum_quick/core/constants/app_colors.dart';
import 'package:yum_quick/core/presentation/components/offline_banner.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_event.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;
          final displayName = user != null && user.fullName.isNotEmpty
              ? user.fullName
              : 'John Smith';
          final displayEmail = user != null && user.email.isNotEmpty
              ? user.email
              : 'Loremipsum@email.com';

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                const OfflineBanner(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 40),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(44),
                        bottomLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: Offset(-4, 0),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 28,
                        right: 24,
                        top: 36,
                        bottom: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white24,
                                backgroundImage: user?.image != null
                                    ? CachedNetworkImageProvider(user!.image!)
                                    : null,
                                child: user?.image == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 32,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      displayEmail,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          _buildMenuItem(
                            iconPath: AppAssets.icOrders,
                            title: 'My Orders',
                            onTap: () => context.go('/orders'),
                          ),

                          _buildMenuItem(
                            iconPath: AppAssets.icProfile,
                            title: 'My Profile',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Profile details are up to date.',
                                  ),
                                ),
                              );
                            },
                          ),

                          _buildMenuItem(
                            iconPath: AppAssets.icLocation,
                            title: 'Delivery Address',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Delivery address saved.'),
                                ),
                              );
                            },
                          ),

                          _buildMenuItem(
                            iconPath: AppAssets.icPayment,
                            title: 'Payment Methods',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Payment methods configured.'),
                                ),
                              );
                            },
                          ),

                          _buildMenuItem(
                            iconPath: AppAssets.icInfo,
                            title: 'Help & FAQs',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Help Center: support@yumquick.com',
                                  ),
                                ),
                              );
                            },
                          ),

                          _buildMenuItem(
                            iconPath: AppAssets.icSettings,
                            title: 'Settings',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'App version 1.0.0 (Bictree Submission)',
                                  ),
                                ),
                              );
                            },
                          ),

                          _buildMenuItem(
                            iconPath: AppAssets.icLogout,
                            title: 'Log Out',
                            onTap: () => _showLogoutDialog(context),
                            showDivider: false,
                          ),
                        ],
                      ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.chipOrangeTint,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      AppAssets.icLogout,
                      width: 28,
                      height: 28,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to log out from YumQuick?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppColors.textPrimary.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.creamButton,
                            foregroundColor: AppColors.primaryOrange,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogCtx).pop(true);
                            context.read<AuthBloc>().add(const LogoutReq());
                            context.read<CartBloc>().add(const ClearCartReq());
                            context.go('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text(
                            'Yes, Log Out',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(9),
                  child: Image.asset(
                    iconPath,
                    color: AppColors.primaryOrange,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: const EdgeInsets.only(left: 54, top: 4, bottom: 4),
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
      ],
    );
  }
}
