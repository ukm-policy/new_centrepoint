import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';

class NotifikasiSettingsScreen extends StatefulWidget {
  const NotifikasiSettingsScreen({super.key});

  @override
  State<NotifikasiSettingsScreen> createState() => _NotifikasiSettingsScreenState();
}

class _NotifikasiSettingsScreenState extends State<NotifikasiSettingsScreen> {
  bool _globalNotif = true;
  bool _notifPoin = true;
  bool _notifKegiatan = true;
  bool _notifAbsensi = true;
  bool _notifUangKhas = false;
  bool _notifPengumuman = true;
  bool _notifSistem = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginPage,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
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
                Text(
                  'Notifikasi',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
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
                      value: _globalNotif,
                      activeThumbColor: AppColors.primaryContainer,
                      activeTrackColor: AppColors.primaryContainer.withValues(alpha: 0.4),
                      onChanged: (v) => setState(() => _globalNotif = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('KATEGORI NOTIFIKASI', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, letterSpacing: 0.5)),
              const SizedBox(height: 8),

              // Detail List Switch
              Opacity(
                opacity: _globalNotif ? 1.0 : 0.5,
                child: AbsorbPointer(
                  absorbing: !_globalNotif,
                  child: BrutalistCard(
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.surfaceContainerLowest,
                    child: Column(
                      children: [
                        _NotifItem(
                          title: 'Poin Keaktifan',
                          subtitle: 'Notifikasi saat poin bertambah/berkurang',
                          value: _notifPoin,
                          onChanged: (v) => setState(() => _notifPoin = v),
                        ),
                        const Divider(height: 1, color: AppColors.borderSlate),
                        _NotifItem(
                          title: 'Kegiatan Baru',
                          subtitle: 'Notifikasi rapat atau acara bidang baru',
                          value: _notifKegiatan,
                          onChanged: (v) => setState(() => _notifKegiatan = v),
                        ),
                        const Divider(height: 1, color: AppColors.borderSlate),
                        _NotifItem(
                          title: 'Absensi & Kehadiran',
                          subtitle: 'Pengingat absensi atau status verifikasi hadir',
                          value: _notifAbsensi,
                          onChanged: (v) => setState(() => _notifAbsensi = v),
                        ),
                        const Divider(height: 1, color: AppColors.borderSlate),
                        _NotifItem(
                          title: 'Uang Khas bulanan',
                          subtitle: 'Tagihan bulanan atau status pembayaran',
                          value: _notifUangKhas,
                          onChanged: (v) => setState(() => _notifUangKhas = v),
                        ),
                        const Divider(height: 1, color: AppColors.borderSlate),
                        _NotifItem(
                          title: 'Pengumuman / Inbox',
                          subtitle: 'Pemberitahuan broadcast penting dari pengurus',
                          value: _notifPengumuman,
                          onChanged: (v) => setState(() => _notifPengumuman = v),
                        ),
                        const Divider(height: 1, color: AppColors.borderSlate),
                        _NotifItem(
                          title: 'Sistem & Keamanan',
                          subtitle: 'Perubahan data profil atau sesi login baru',
                          value: _notifSistem,
                          onChanged: (v) => setState(() => _notifSistem = v),
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
