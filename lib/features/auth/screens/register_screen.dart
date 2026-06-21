import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi sukses. Silakan lengkapi profil.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pushReplacement('/lengkapi-profil');
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
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

                    // ── Back button ──────────────────────────────────────────
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

                    // ── Header ───────────────────────────────────────────────
                    Text(
                      'BUAT AKUN',
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLgMobile.copyWith(
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan email dan password untuk membuat akun.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 16),
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 20),

                    // ── Email ────────────────────────────────────────────────
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
                    const SizedBox(height: AppSpacing.stackGap),

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

                    // ── Konfirmasi Password ──────────────────────────────────
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
                            label: 'LANJUTKAN',
                            icon: Icons.arrow_forward,
                            onPressed: _submit,
                          ),
                    const SizedBox(height: AppSpacing.stackGap),

                    // ── Divider OR ───────────────────────────────────────────
                    Row(children: [
                      const Expanded(child: MyDivider(color: AppColors.borderSlate, height: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('ATAU', style: AppTypography.labelBold.copyWith(
                          color: AppColors.tertiary,
                        )),
                      ),
                      const Expanded(child: MyDivider(color: AppColors.borderSlate, height: 1)),
                    ]),
                    const SizedBox(height: AppSpacing.stackGap),

                    // ── Google Sign Up ───────────────────────────────────────
                    BrutalistButton(
                      label: 'Daftar dengan Google',
                      variant: BrutalistButtonVariant.secondary,
                      onPressed: () => context.pushReplacement('/setup-password'),
                    ),
                    const SizedBox(height: 24),

                    // ── Footer ───────────────────────────────────────────────
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('Sudah punya akun? ', style: AppTypography.bodyMd),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Masuk',
                          style: AppTypography.labelBold.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ]),
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
