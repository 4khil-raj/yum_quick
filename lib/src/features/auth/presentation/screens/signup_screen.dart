import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yum_quick/src/core/constants/app_assets.dart';
import 'package:yum_quick/src/core/constants/app_colors.dart';
import 'package:yum_quick/src/core/presentation/components/app_text_field.dart';
import 'package:yum_quick/src/core/presentation/components/offline_banner.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Please log in.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            const OfflineBanner(),
            // 1. Curved Yellow Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.primaryOrange,
                      size: 32,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'New Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // 2. White Curved Card Body
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full name
                      const Text(
                        'Full name',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _nameController,
                        hintText: 'example@example.com',
                        validator: (val) => val == null || val.isEmpty
                            ? 'Please enter your name'
                            : null,
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
                        hintText: '••••••••••••',
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
                        validator: (val) => val == null || val.length < 6
                            ? 'Password must be 6+ characters'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _emailController,
                        hintText: 'example@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || !val.contains('@')
                            ? 'Please enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Mobile Number
                      const Text(
                        'Mobile Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _mobileController,
                        hintText: '+ 123 456 789',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Date of birth
                      const Text(
                        'Date of birth',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _dobController,
                        hintText: 'DD / MM / YYYY',
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 18),

                      // Terms
                      Center(
                        child: Text(
                          'By continuing, you agree to\nTerms of Use and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: AppColors.textPrimary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Centered Orange Pill Sign Up Button
                      Center(
                        child: SizedBox(
                          width: 190,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _onRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // or sign up with
                      Center(
                        child: Text(
                          'or sign up with',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Social Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialCircle(
                            iconPath: AppAssets.icGoogle,
                            onTap: () {},
                          ),
                          const SizedBox(width: 16),
                          _buildSocialCircle(
                            iconPath: AppAssets.icFacebook,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: const Text(
                              'Log In',
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
