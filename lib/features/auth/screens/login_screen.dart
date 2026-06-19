import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.marginPage),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.blackCharcoal, width: 2),
                boxShadow: const [AppColors.hardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Column(
                    children: [
                      Text(
                        'POLICY CENTREPOINT',
                        textAlign: TextAlign.center,
                        style: AppTypography.displayLgMobile.copyWith(
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selamat datang kembali. Silakan masuk untuk melanjutkan.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const MyDivider(color: AppColors.borderSlate),
                  const SizedBox(height: 16),

                  // Email field
                  _FieldLabel(label: 'EMAIL ADDRESS'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTypography.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'nama@email.com',
                      prefixIcon: const Icon(Icons.mail_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // Password field
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _FieldLabel(label: 'PASSWORD'),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Lupa?',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    style: AppTypography.bodyMd,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  BrutalistButton(
                    label: 'MASUK',
                    icon: Icons.arrow_forward,
                    onPressed: () => context.go('/'),
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // Divider OR
                  Row(
                    children: [
                      const Expanded(child: MyDivider(color: AppColors.borderSlate, height: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'ATAU',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.tertiary,
                          ),
                        ),
                      ),
                      const Expanded(child: MyDivider(color: AppColors.borderSlate, height: 1)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // Google sign in
                  BrutalistButton(
                    label: 'Masuk dengan Google',
                    variant: BrutalistButtonVariant.secondary,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  const MyDivider(color: AppColors.borderSlate),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: AppTypography.bodyMd,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Daftar sekarang',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelBold.copyWith(
        color: AppColors.onSurface,
        letterSpacing: 0.5,
      ),
    );
  }
}
