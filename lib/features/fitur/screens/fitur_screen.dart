import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
    this.implemented = true,
  });
  final IconData icon;
  final String label;
  final String route;
  final bool implemented;
}

class _RoleData {
  const _RoleData({
    required this.title,
    required this.level,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.items,
  });
  final String title;
  final int level;
  final Color badgeColor;
  final Color badgeTextColor;
  final List<_MenuItem> items;
}

const _roles = [
  _RoleData(
    title: 'User Public',
    level: 0,
    badgeColor: AppColors.surfaceContainer,
    badgeTextColor: AppColors.tertiary,
    items: [
      _MenuItem(icon: Icons.person_outline, label: 'Edit Profil Sendiri', route: '/profil/edit'),
      _MenuItem(icon: Icons.hourglass_top_outlined, label: 'Status Verifikasi Akun', route: '/pending'),
      _MenuItem(icon: Icons.how_to_reg_outlined, label: 'Open Recruitment', route: '/or'),
    ],
  ),
  _RoleData(
    title: 'Anggota Umum',
    level: 1,
    badgeColor: AppColors.surfaceContainerHighest,
    badgeTextColor: AppColors.onSurface,
    items: [
      _MenuItem(icon: Icons.groups, label: 'Daftar Anggota', route: '/anggota'),
      _MenuItem(icon: Icons.account_balance_wallet_outlined, label: 'Uang Khas (Milik Sendiri)', route: '/uang-khas'),
      _MenuItem(icon: Icons.workspace_premium_outlined, label: 'Poin Keaktifan', route: '/poin'),
      _MenuItem(icon: Icons.mail_outline, label: 'Inbox & Pengumuman', route: '/inbox'),
    ],
  ),
  _RoleData(
    title: 'Demisioner',
    level: 1,
    badgeColor: AppColors.primaryContainer,
    badgeTextColor: Colors.white,
    items: [
      _MenuItem(icon: Icons.history, label: 'Riwayat Kegiatan', route: '/kegiatan/riwayat'),
      _MenuItem(icon: Icons.groups, label: 'Daftar Anggota', route: '/anggota'),
      _MenuItem(icon: Icons.workspace_premium_outlined, label: 'Arsip Poin Keaktifan', route: '/poin'),
      _MenuItem(icon: Icons.mail_outline, label: 'Inbox & Pengumuman', route: '/inbox'),
    ],
  ),
  _RoleData(
    title: 'Anggota Bidang',
    level: 2,
    badgeColor: AppColors.secondaryContainer,
    badgeTextColor: AppColors.onSecondaryContainer,
    items: [
      _MenuItem(icon: Icons.history, label: 'Riwayat Absensi Bidang', route: '/absensi/riwayat-sekret'),
      _MenuItem(icon: Icons.info_outline, label: 'Info Internal Bidang', route: '/fitur/bidang'),
    ],
  ),
  _RoleData(
    title: 'Ketua Bidang',
    level: 3,
    badgeColor: AppColors.tertiaryContainer,
    badgeTextColor: AppColors.onTertiaryContainer,
    items: [
      _MenuItem(icon: Icons.qr_code, label: 'Generate QR Absensi', route: '/admin/qr-generator'),
      _MenuItem(icon: Icons.event_available_outlined, label: 'Kelola Kegiatan Bidang', route: '/admin/kegiatan'),
      _MenuItem(icon: Icons.how_to_reg_outlined, label: 'Kelola Absensi Anggota', route: '/absensi/riwayat-sekret'),
      _MenuItem(icon: Icons.stars_outlined, label: 'Kelola Poin Anggota', route: '/admin/poin'),
      _MenuItem(icon: Icons.manage_accounts_outlined, label: 'Kelola Data Anggota Bidang', route: '/admin/anggota', implemented: false),
    ],
  ),
  _RoleData(
    title: 'Bendahara Umum',
    level: 4,
    badgeColor: AppColors.errorContainer,
    badgeTextColor: AppColors.onErrorContainer,
    items: [
      _MenuItem(icon: Icons.payments_outlined, label: 'Uang Khas Semua Anggota', route: '/admin/uang-khas'),
      _MenuItem(icon: Icons.verified_outlined, label: 'Verifikasi Pembayaran', route: '/admin/uang-khas/verifikasi'),
      _MenuItem(icon: Icons.bar_chart, label: 'Rekap Keuangan', route: '/admin/keuangan'),
      _MenuItem(icon: Icons.download_outlined, label: 'Export Laporan Keuangan', route: '/admin/keuangan/export', implemented: false),
    ],
  ),
  _RoleData(
    title: 'Sekretaris Umum',
    level: 4,
    badgeColor: AppColors.primaryContainer,
    badgeTextColor: AppColors.onPrimaryContainer,
    items: [
      _MenuItem(icon: Icons.event_available_outlined, label: 'Kelola Kegiatan Semua Bidang', route: '/admin/kegiatan'),
      _MenuItem(icon: Icons.article_outlined, label: 'Kelola Berita & Pengumuman', route: '/admin/berita'),
      _MenuItem(icon: Icons.campaign_outlined, label: 'Kirim Pengumuman', route: '/admin/pengumuman/buat'),
      _MenuItem(icon: Icons.how_to_reg_outlined, label: 'Kelola Absensi Semua Anggota', route: '/absensi/riwayat-sekret'),
      _MenuItem(icon: Icons.manage_accounts_outlined, label: 'Kelola Profil Anggota', route: '/admin/anggota', implemented: false),
      _MenuItem(icon: Icons.stars_outlined, label: 'Kelola Poin Semua Anggota', route: '/admin/poin'),
      _MenuItem(icon: Icons.how_to_reg_outlined, label: 'Verifikasi Anggota Baru', route: '/admin/verifikasi'),
      _MenuItem(icon: Icons.assignment_ind_outlined, label: 'Dashboard Open Recruitment', route: '/admin/or'),
    ],
  ),
  _RoleData(
    title: 'Ketua Umum',
    level: 5,
    badgeColor: AppColors.primary,
    badgeTextColor: AppColors.onPrimary,
    items: [
      _MenuItem(icon: Icons.how_to_reg_outlined, label: 'Kelola Periode OR', route: '/admin/or/kelola'),
      _MenuItem(icon: Icons.calendar_month_outlined, label: 'Kelola Periode Kepengurusan', route: '/admin/periode'),
      _MenuItem(icon: Icons.badge_outlined, label: 'Assign Jabatan Anggota', route: '/admin/periode/jabatan'),
      _MenuItem(icon: Icons.admin_panel_settings_outlined, label: 'Panel Admin Penuh', route: '/admin'),
      _MenuItem(icon: Icons.receipt_long_outlined, label: 'Log Aktivitas Sistem', route: '/admin/log'),
    ],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class FiturScreen extends StatelessWidget {
  const FiturScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: FloatingAppBar(title: 'Fitur')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, AppSpacing.stackGap,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (AppSession.isAdmin && AppSession.kodeRole != 'demisioner') ...[
                _AdminAccessBanner(),
                const SizedBox(height: 28),
              ],
              for (final role in _roles) ...[
                if (AppSession.kodeRole == 'demisioner') ...[
                  if (role.title == 'User Public' || role.title == 'Demisioner') ...[
                    _RoleSection(role: role),
                    const SizedBox(height: 24),
                  ],
                ] else ...[
                  if (role.title != 'Demisioner' && role.level <= AppSession.level) ...[
                    _RoleSection(role: role),
                    const SizedBox(height: 24),
                  ],
                ],
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Admin Access Banner ───────────────────────────────────────────────────────

class _AdminAccessBanner extends StatefulWidget {
  @override
  State<_AdminAccessBanner> createState() => _AdminAccessBannerState();
}

class _AdminAccessBannerState extends State<_AdminAccessBanner> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('Administrator', style: AppTypography.headlineSm)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.blackCharcoal,
            borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
            boxShadow: const [AppColors.hardShadowSm],
          ),
          child: Text(
            'ADMIN',
            style: AppTypography.labelBold.copyWith(
              color: Colors.white,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      const MyDivider(color: AppColors.blackCharcoal, height: 1),
      const SizedBox(height: 10),
      GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () => context.push('/admin'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: _pressed ? Matrix4.translationValues(3, 3, 0) : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.innerPadding,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.blackCharcoal,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: AppColors.blackCharcoal, width: 2),
            boxShadow: [BoxShadow(
              color: AppColors.blackCharcoal,
              offset: _pressed ? const Offset(1, 1) : const Offset(3, 3),
              blurRadius: 0,
            )],
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel Admin',
                  style: AppTypography.bodyLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kelola seluruh fitur & master data',
                  style: AppTypography.bodyMd.copyWith(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            )),
            const Icon(Icons.chevron_right, size: 18, color: Colors.white),
          ]),
        ),
      ),
    ]);
  }
}

// ── Section ───────────────────────────────────────────────────────────────────

class _RoleSection extends StatelessWidget {
  const _RoleSection({required this.role});
  final _RoleData role;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          children: [
            Expanded(
              child: Text(role.title, style: AppTypography.headlineSm),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: role.badgeColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                boxShadow: const [AppColors.hardShadowSm],
              ),
              child: Text(
                'Lv.${role.level}',
                style: AppTypography.labelBold.copyWith(
                  color: role.badgeTextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const MyDivider(color: AppColors.blackCharcoal, height: 1),
        const SizedBox(height: 10),

        // Menu buttons
        ...role.items.map((item) => _FeatureButton(item: item)),
      ],
    );
  }
}

// ── Feature Button ────────────────────────────────────────────────────────────

class _FeatureButton extends StatefulWidget {
  const _FeatureButton({required this.item});
  final _MenuItem item;

  @override
  State<_FeatureButton> createState() => _FeatureButtonState();
}

class _FeatureButtonState extends State<_FeatureButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          if (item.implemented) {
            context.push(item.route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.label} — Segera hadir',
                  style: AppTypography.bodyMd.copyWith(color: Colors.white)),
                backgroundColor: AppColors.blackCharcoal,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: _pressed
              ? Matrix4.translationValues(3, 3, 0)
              : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.innerPadding,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: item.implemented
                ? AppColors.surfaceContainerLowest
                : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: AppColors.blackCharcoal, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.blackCharcoal,
                offset: _pressed ? const Offset(1, 1) : const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: item.implemented
                    ? AppColors.onSurface
                    : AppColors.tertiary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTypography.bodyLg.copyWith(
                    color: item.implemented
                        ? AppColors.onSurface
                        : AppColors.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!item.implemented)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppColors.borderSlate, width: 1),
                  ),
                  child: Text('Soon',
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.tertiary,
                      fontSize: 10,
                    )),
                )
              else
                const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
            ],
          ),
        ),
      ),
    );
  }
}
