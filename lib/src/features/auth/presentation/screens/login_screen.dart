import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/app_text_field.dart';
import 'package:yum_quick/src/core/presentation/components/offline_banner.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'emilys');
  final _passwordController = TextEditingController(text: 'emilyspass');
  bool _obscurePassword = true;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Unauthenticated &&
        authState.savedUsername != null &&
        authState.savedUsername!.isNotEmpty) {
      _usernameController.text = authState.savedUsername!;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _autoValidate = true);
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginReq(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${state.user.fullName}!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is Unauthenticated &&
              state.sessionExpiredMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.sessionExpiredMessage!),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            bottom: true,
            child: Column(
              children: [
                const OfflineBanner(),
                // 1. Curved Yellow Header with Back Button & Bold White Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/welcome');
                          }
                        },
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.primaryOrange,
                          size: 32,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance leading back button
                    ],
                  ),
                ),

                // 2. White Curved Card Body
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autoValidate
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.45,
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.65,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Username / Email
                          const Text(
                            'Email or Mobile Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _usernameController,
                            hintText: 'example@example.com',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your username';
                              }
                              if (val.trim().length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Image.asset(
                                AppAssets.icEye,
                                width: 20,
                                height: 20,
                                color: _obscurePassword
                                    ? AppColors.textMuted
                                    : AppColors.primaryOrange,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (val.length < 4) {
                                return 'Password must be at least 4 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password reset instructions sent.',
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot Password',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // // Test credentials quick-pill helper
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: InkWell(
                          //     onTap: () {
                          //       _usernameController.text = 'emilys';
                          //       _passwordController.text = 'emilyspass';
                          //     },
                          //     child: Container(
                          //       padding: const EdgeInsets.symmetric(
                          //         horizontal: 10,
                          //         vertical: 4,
                          //       ),
                          //       decoration: BoxDecoration(
                          //         color: AppColors.chipOrangeTint,
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //       child: const Text(
                          //         'Fill Demo: emilys / emilyspass',
                          //         style: TextStyle(
                          //           fontSize: 12,
                          //           fontWeight: FontWeight.w600,
                          //           color: AppColors.primaryOrange,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 24),

                          // Centered Orange Pill Log In Button
                          Center(
                            child: SizedBox(
                              width: 190,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryOrange,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // or sign up with
                          Center(
                            child: Text(
                              'or sign up with',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Social & Biometric Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialCircle(
                                iconPath: AppAssets.icGoogle,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Google Sign-in available in release build.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              _buildSocialCircle(
                                iconPath: AppAssets.icFacebook,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Facebook Sign-in available in release build.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // Sign up navigation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: AppColors.textPrimary.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.push('/signup'),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
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

  Widget _buildSocialCircle({
    required String iconPath,
    required VoidCallback onTap,
    bool isOrangeTint = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isOrangeTint ? AppColors.primaryOrange : AppColors.border,
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(11),
        child: Image.asset(
          iconPath,
          fit: BoxFit.contain,
          color: isOrangeTint ? AppColors.primaryOrange : null,
        ),
      ),
    );
  }
}
