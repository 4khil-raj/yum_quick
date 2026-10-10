import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/curved_header.dart';

import '../../../auth/state/auth_bloc.dart';
import '../../../auth/state/auth_event.dart';
import '../../../auth/state/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;
          final isBiometricEnabled = state is Authenticated
              ? state.isBiometricEnabled
              : false;

          return Column(
            children: [
              CurvedHeader(
                title: const Text(
                  'My Profile',
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
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // User Avatar & Name Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.chipOrangeTint,
                              backgroundImage: user?.image != null
                                  ? CachedNetworkImageProvider(user!.image!)
                                  : null,
                              child: user?.image == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: AppColors.primaryOrange,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName.isNotEmpty == true
                                        ? user!.fullName
                                        : 'Emily Smith',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email.isNotEmpty == true
                                        ? user!.email
                                        : 'emily@example.com',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${user?.username ?? 'emilys'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Settings Options Group
                      _buildSettingsGroup([
                        _buildSettingsTile(
                          icon: AppAssets.icFingerprint,
                          title: 'Biometric Unlock',
                          trailing: Switch(
                            value: isBiometricEnabled,
                            activeThumbColor: AppColors.primaryOrange,
                            onChanged: (val) {
                              context.read<AuthBloc>().add(
                                EnableBiometricReq(val),
                              );
                            },
                          ),
                        ),
                        _buildSettingsTile(
                          icon: AppAssets.icOrders,
                          title: 'My Orders',
                          onTap: () => context.go('/orders'),
                        ),
                        _buildSettingsTile(
                          icon: AppAssets.icLocation,
                          title: 'Delivery Addresses',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Delivery address saved.'),
                              ),
                            );
                          },
                        ),
                        _buildSettingsTile(
                          icon: AppAssets.icPayment,
                          title: 'Payment Methods',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Manage UPI & Cards'),
                              ),
                            );
                          },
                        ),
                        _buildSettingsTile(
                          icon: AppAssets.icSupport,
                          title: 'Help & Customer Support',
                          onTap: () => context.push('/support'),
                        ),
                        _buildSettingsTile(
                          icon: AppAssets.icInfo,
                          title: 'About YumQuick',
                          subtitle:
                              'Version 1.0.0 • Bictree Technical Assignment',
                          onTap: () {},
                        ),
                      ]),
                      const SizedBox(height: 24),

                      // Logout Button
                      InkWell(
                        onTap: () {
                          context.read<AuthBloc>().add(const LogoutReq());
                          context.go('/login');
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppAssets.icLogout,
                                width: 20,
                                height: 20,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required String icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: AppColors.surfaceSoft,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(9),
        child: Image.asset(
          icon,
          color: AppColors.primaryOrange,
          fit: BoxFit.contain,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            )
          : null,
      trailing:
          trailing ??
          Image.asset(
            AppAssets.icChevronRight,
            width: 14,
            height: 14,
            color: AppColors.textSecondary,
          ),
      onTap: onTap,
    );
  }
}
