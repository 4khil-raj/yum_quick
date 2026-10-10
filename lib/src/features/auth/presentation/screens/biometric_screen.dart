import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/app_button.dart';

import '../../state/auth_bloc.dart';
import '../../state/auth_event.dart';

class BiometricScreen extends StatelessWidget {
  const BiometricScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(AppAssets.icArrowBack, width: 20, height: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Biometric Setup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.chipOrangeTint,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(28),
                child: Image.asset(
                  AppAssets.icFingerprint,
                  color: AppColors.primaryOrange,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Unlock with Biometrics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enable fingerprint or Face ID for fast and secure access to YumQuick without typing your password every time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              AppButton(
                text: 'Enable Biometrics',
                onPressed: () {
                  context.read<AuthBloc>().add(const EnableBiometricReq(true));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Biometrics enabled for this account!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.pop();
                },
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Skip for Now',
                variant: AppButtonVariant.outlined,
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
