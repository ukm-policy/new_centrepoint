import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _success = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          child: Center(
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppSpacing.radius),
                            border: Border.all(color: AppColors.blackCharcoal, width: 2),
                            boxShadow: const [AppColors.hardShadowSm],
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.arrow_back, size: 16, color: AppColors.onSurface),
                            const SizedBox(width: 6),
                            Text('Kembali', style: AppTypography.labelBold),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header
                    Text(
                      'LUPA PASSWORD',
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLgMobile.copyWith(
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan email terdaftar untuk menerima link reset password.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 16),
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 20),

                    if (!_success) ...[
                      // Email
                      const _FieldLabel(label: 'EMAIL ADDRESS'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTypography.bodyMd,
                        decoration: const InputDecoration(
                          hintText: 'nama@email.com',
                          prefixIcon: Icon(Icons.mail_outline, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                          if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : BrutalistButton(
                              label: 'KIRIM LINK RESET',
                              icon: Icons.send_outlined,
                              onPressed: _submit,
                            ),
                    ] else ...[
                      // Success alert box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.blackCharcoal, width: 2),
                          boxShadow: const [AppColors.hardShadowSm],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.success, size: 24),
                                SizedBox(width: 10),
                                Text(
                                  'Email Terkirim!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Link reset password telah dikirim ke:\n${_emailCtrl.text.trim()}',
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      BrutalistButton(
                        label: 'KEMBALI KE LOGIN',
                        variant: BrutalistButtonVariant.secondary,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ],
                ),
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
  Widget build(BuildContext context) => Text(
    label,
    style: AppTypography.labelBold.copyWith(
      color: AppColors.onSurface,
      letterSpacing: 0.5,
    ),
  );
}
