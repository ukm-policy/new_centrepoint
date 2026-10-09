import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/utils/feedback.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';

class NotifikasiSettingsScreen extends StatefulWidget {
  const NotifikasiSettingsScreen({super.key});

  @override
  State<NotifikasiSettingsScreen> createState() => _NotifikasiSettingsScreenState();
}

class _NotifikasiSettingsScreenState extends State<NotifikasiSettingsScreen> {
  /// Nilai bawaan tiap kategori notifikasi.
  static const _defaults = {
    'global': true,
    'poin': true,
    'kegiatan': true,
    'absensi': true,
    'uang_khas': false,
    'pengumuman': true,
    'sistem': false,
  };

  late final Map<String, bool> _prefs = {
    ..._defaults,
    ...?(Supabase.instance.client.auth.currentUser?.userMetadata?['notif_prefs'] as Map?)
        ?.map((k, v) => MapEntry('$k', v == true)),
  };

  bool _get(String key) => _prefs[key] ?? _defaults[key] ?? false;

  /// Simpan preferensi ke metadata akun (ikut ke perangkat lain).
  Future<void> _set(String key, bool value) async {
    final previous = _get(key);
    setState(() => _prefs[key] = value);
    final ok = await runWithFeedback(
      context,
      () => Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'notif_prefs': _prefs}),
      ),
      errorPrefix: 'Gagal menyimpan pengaturan',
    );
    if (!ok && mounted) setState(() => _prefs[key] = previous);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: PageAppBar(title: 'Notifikasi'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Global Switch Card
              BrutalistCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.surfaceContainerLowest,
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, size: 24, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Push Notification', style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                          Text('Aktifkan notifikasi secara global', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _get('global'),
                      activeThumbColor: AppColors.primaryContainer,
                      activeTrackColor: AppColors.primaryContainer.withValues(alpha: 0.4),
                      onChanged: (v) => _set('global', v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pilihan Anda tersimpan di akun. Notifikasi push ke perangkat belum '
                'tersedia — untuk sementara, pemberitahuan tampil di Inbox.',
                style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
              ),
              const SizedBox(height: 24),

              Text('KATEGORI NOTIFIKASI', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, letterSpacing: 0.5)),
              const SizedBox(height: 8),

              // Detail List Switch
              Opacity(
                opacity: _get('global') ? 1.0 : 0.5,
                child: AbsorbPointer(
                  absorbing: !_get('global'),
                  child: BrutalistCard(
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.surfaceContainerLowest,
                    child: Column(
                      children: [
                        _NotifItem(
                          title: 'Poin Keaktifan',
                          subtitle: 'Notifikasi saat poin bertambah/berkurang',
                          value: _get('poin'),
                          onChanged: (v) => _set('poin', v),
                        ),
                        const Divider(height: 1, color: AppColors.borderSlate),
                        _NotifItem(
                          title: 'Kegiatan Baru',
                          subtitle: 'Notifikasi rapat atau acara bidang baru',
                          value: _get('kegiatan'),
                          onChanged: (v) => _set('kegiatan', v),
                        ),
                        const Divider(height: 1, color: AppColors.borderSlate),
                        _NotifItem(
                          title: 'Absensi & Kehadiran',
                          subtitle: 'Pengingat absensi atau status verifikasi hadir',
                          value: _get('absensi'),
                          onChanged: (v) => _set('absensi', v),
                        ),
                        const Divider(height: 1, color: AppColors.borderSlate),
                        _NotifItem(
                          title: 'Uang Khas bulanan',
                          subtitle: 'Tagihan bulanan atau status pembayaran',
                          value: _get('uang_khas'),
                          onChanged: (v) => _set('uang_khas', v),
                        ),
                        const Divider(height: 1, color: AppColors.borderSlate),
                        _NotifItem(
                          title: 'Pengumuman / Inbox',
                          subtitle: 'Pemberitahuan broadcast penting dari pengurus',
                          value: _get('pengumuman'),
                          onChanged: (v) => _set('pengumuman', v),
                        ),
                        const Divider(height: 1, color: AppColors.borderSlate),
                        _NotifItem(
                          title: 'Sistem & Keamanan',
                          subtitle: 'Perubahan data profil atau sesi login baru',
                          value: _get('sistem'),
                          onChanged: (v) => _set('sistem', v),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  const _NotifItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                Text(subtitle, style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primaryContainer,
            activeTrackColor: AppColors.primaryContainer.withValues(alpha: 0.4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
