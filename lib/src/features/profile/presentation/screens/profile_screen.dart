import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';

import '../../../auth/state/auth_bloc.dart';
import '../../../auth/state/auth_event.dart';
import '../../../auth/state/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;
        final displayName = user != null && user.fullName.isNotEmpty
            ? user.fullName
            : 'John Smith';
        final displayEmail = user != null && user.email.isNotEmpty
            ? user.email
            : 'Loremipsum@email.com';

        return Scaffold(
          backgroundColor: AppColors.primaryYellow,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Curved Orange Side-Drawer Styled Container
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
                          // User Avatar + Name + Email
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

                          // 1. My Orders
                          _buildMenuItem(
                            iconPath: AppAssets.icOrders,
                            title: 'My Orders',
                            onTap: () => context.go('/orders'),
                          ),

                          // 2. My Profile
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

                          // 3. Delivery Address
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

                          // 4. Payment Methods
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

                          // 5. Contact Us
                          _buildMenuItem(
                            iconPath: AppAssets.icSupport,
                            title: 'Contact Us',
                            onTap: () => context.push('/support'),
                          ),

                          // 6. Help & FAQs
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

                          // 7. Settings
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

                          // 8. Log Out
                          _buildMenuItem(
                            iconPath: AppAssets.icLogout,
                            title: 'Log Out',
                            onTap: () {
                              context.read<AuthBloc>().add(const LogoutReq());
                              context.go('/welcome');
                            },
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                // White Circle Icon with Orange Glyph
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
