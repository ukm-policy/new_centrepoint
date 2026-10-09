import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/utils/feedback.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';

/// Dibuka otomatis setelah user mengklik link reset password dari email.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await runWithFeedback(
      context,
      () => Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordCtrl.text),
      ),
      success: 'Password berhasil diperbarui.',
      errorPrefix: 'Gagal memperbarui password',
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      SessionController.instance.finishPasswordRecovery();
      context.go('/');
    }
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
                    Text(
                      'PASSWORD BARU',
                      textAlign: TextAlign.center,
                      style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buat password baru untuk akun Anda.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 8),
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      style: AppTypography.bodyMd,
                      decoration: InputDecoration(
                        labelText: 'Password baru',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _konfirmasiCtrl,
                      obscureText: _obscure,
                      style: AppTypography.bodyMd,
                      decoration: const InputDecoration(
                        labelText: 'Ulangi password baru',
                        prefixIcon: Icon(Icons.lock_reset, size: 20),
                      ),
                      validator: (v) =>
                          v != _passwordCtrl.text ? 'Password tidak sama' : null,
                    ),
                    const SizedBox(height: 24),
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : BrutalistButton(
                            label: 'SIMPAN PASSWORD',
                            icon: Icons.check,
                            onPressed: _submit,
                          ),
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
