import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../core/session/app_session.dart';

class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen> {
  bool _checking = false;

  Future<void> _refreshStatus() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _checking = true);
    try {
      await Supabase.instance.client.auth.refreshSession();
      if (!mounted) return;
      
      final status = AppSession.status;
      if (status == 'active') {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Akun Anda telah terverifikasi! Mengalihkan...',
                style: AppTypography.bodyMd.copyWith(color: Colors.white)),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppSpacing.marginPage),
            duration: const Duration(seconds: 2),
          ),
        );
        router.go('/');
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Akun Anda masih dalam proses verifikasi pengurus.',
                style: AppTypography.bodyMd.copyWith(color: Colors.white)),
            backgroundColor: AppColors.blackCharcoal,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(AppSpacing.marginPage),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui status: $e',
              style: AppTypography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.marginPage),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.blackCharcoal, width: 2.5),
                        boxShadow: const [AppColors.hardShadowSm],
                      ),
                      child: const Icon(
                        Icons.hourglass_empty_outlined,
                        size: 40,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header
                  Text(
                    'MENUNGGU VERIFIKASI',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayLgMobile.copyWith(
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Akun Anda telah berhasil didaftarkan dan sedang menunggu verifikasi oleh Pengurus.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                  ),
                  const SizedBox(height: 20),
                  const MyDivider(color: AppColors.borderSlate),
                  const SizedBox(height: 20),

                  // User Info Card
                  BrutalistCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppColors.surfaceContainerLowest,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DATA PENDAFTARAN',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.tertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Nama Lengkap', value: AppSession.nama),
                        const SizedBox(height: 8),
                        _InfoRow(label: 'NIM', value: AppSession.nim),
                        const SizedBox(height: 8),
                        _InfoRow(label: 'Email', value: 'user.public@email.com'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Proses verifikasi biasanya memakan waktu 1x24 jam. Pengurus (Sekretaris Umum/Ketua Umum) akan memeriksa kelayakan berkas Anda.',
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.tertiary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Buttons
                  _checking
                      ? const Center(child: CircularProgressIndicator())
                      : BrutalistButton(
                          label: 'REFRESH STATUS',
                          icon: Icons.refresh_outlined,
                          onPressed: _refreshStatus,
                        ),
                  const SizedBox(height: 12),
                  BrutalistButton(
                    label: 'LOGOUT / KELUAR',
                    variant: BrutalistButtonVariant.secondary,
                    icon: Icons.logout_outlined,
                    onPressed: () async {
                      final router = GoRouter.of(context);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      try {
                        await Supabase.instance.client.auth.signOut();
                        if (mounted) {
                          router.go('/login');
                        }
                      } catch (e) {
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Gagal keluar: $e',
                                  style: AppTypography.bodyMd.copyWith(color: Colors.white)),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(AppSpacing.marginPage),
                            ),
                          );
                        }
                      }
                    },
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
