import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';

class SetupPasswordScreen extends StatefulWidget {
  const SetupPasswordScreen({super.key});

  @override
  State<SetupPasswordScreen> createState() => _SetupPasswordScreenState();
}

class _SetupPasswordScreenState extends State<SetupPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _loading = false;

  // Mock: email yang sudah didapat dari Google OAuth
  static const _googleEmail = 'user@gmail.com';
  static const _googleNama = 'User Google';

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    context.pushReplacement('/lengkapi-profil');
  }

  void _skip() => context.pushReplacement('/lengkapi-profil');

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

                    // ── Google account info ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        border: Border.all(color: AppColors.borderSlate, width: 1.5),
                      ),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.blackCharcoal, width: 2),
                          ),
                          child: const Icon(Icons.person_outline, size: 20,
                            color: AppColors.tertiary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_googleNama, style: AppTypography.bodyLg.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                            Text(_googleEmail, style: AppTypography.bodyMd.copyWith(
                              color: AppColors.tertiary,
                            )),
                          ],
                        )),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                          ),
                          child: Text('Google', style: AppTypography.labelBold.copyWith(
                            color: AppColors.onSuccess, fontSize: 10,
                          )),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    // ── Header ───────────────────────────────────────────────
                    Text(
                      'BUAT PASSWORD',
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLgMobile.copyWith(
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buat password agar kamu juga bisa masuk menggunakan email.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 16),
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 20),

                    // ── Password ─────────────────────────────────────────────
                    const _FieldLabel(label: 'PASSWORD'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      style: AppTypography.bodyMd,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Min. 8 karakter',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                        if (v.length < 8) return 'Password minimal 8 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    _PasswordStrength(password: _passwordCtrl.text),
                    const SizedBox(height: AppSpacing.stackGap),

                    // ── Konfirmasi ────────────────────────────────────────────
                    const _FieldLabel(label: 'KONFIRMASI PASSWORD'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _konfirmasiCtrl,
                      obscureText: _obscureKonfirmasi,
                      style: AppTypography.bodyMd,
                      decoration: InputDecoration(
                        hintText: 'Ulangi password',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscureKonfirmasi = !_obscureKonfirmasi),
                          child: Icon(
                            _obscureKonfirmasi
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                        if (v != _passwordCtrl.text) return 'Password tidak sama';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Submit ───────────────────────────────────────────────
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : BrutalistButton(
                            label: 'SIMPAN',
                            icon: Icons.check,
                            onPressed: _submit,
                          ),
                    const SizedBox(height: 14),

                    // ── Skip ─────────────────────────────────────────────────
                    GestureDetector(
                      onTap: _skip,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lewati, atur nanti',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.tertiary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 14,
                              color: AppColors.tertiary),
                          ],
                        ),
                      ),
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

// ── Password Strength ─────────────────────────────────────────────────────────

class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.password});
  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    final (level, label, color) = _evaluate(password);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Kekuatan Password', style: AppTypography.labelBold.copyWith(
          color: AppColors.tertiary, fontSize: 11,
        )),
        Text(label, style: AppTypography.labelBold.copyWith(
          color: color, fontSize: 11,
        )),
      ]),
      const SizedBox(height: 6),
      Row(children: List.generate(4, (i) => Expanded(
        child: Container(
          height: 4,
          margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
          decoration: BoxDecoration(
            color: i < level ? color : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: i < level ? color : AppColors.borderSlate,
              width: 1,
            ),
          ),
        ),
      ))),
    ]);
  }

  (int, String, Color) _evaluate(String p) {
    int score = 0;
    if (p.length >= 8) score++;
    if (p.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(p)) score++;
    return switch (score) {
      0 || 1 => (1, 'Lemah', AppColors.error),
      2      => (2, 'Cukup', AppColors.secondary),
      3      => (3, 'Kuat', AppColors.success),
      _      => (4, 'Sangat Kuat', AppColors.success),
    };
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

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
