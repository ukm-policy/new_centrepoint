import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../or/or_data.dart';

// ── Mock stats (nanti dari DB) ─────────────────────────────────────────────────

const _kTotalUser = 48;
const _kAnggotaAktif = 36;
const _kPendingVerif = 4;
final _kPendingOR = kApplicants.where((a) => a.status == ApplicantStatus.pending).length;

// ── Admin Menu Data ────────────────────────────────────────────────────────────

class _AdminMenu {
  const _AdminMenu({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.route,
    this.badgeCount = 0,
    this.implemented = true,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final String route;
  final int badgeCount;
  final bool implemented;
}

class _AdminCategory {
  const _AdminCategory({
    required this.label,
    required this.color,
    required this.menus,
  });
  final String label;
  final Color color;
  final List<_AdminMenu> menus;
}

final _kCategories = [
  _AdminCategory(
    label: 'Pengguna & Keanggotaan',
    color: AppColors.primaryContainer,
    menus: [
      _AdminMenu(
        icon: Icons.manage_accounts_outlined,
        label: 'Kelola Akun Pengguna',
        subtitle: '$_kTotalUser pengguna terdaftar',
        route: '/admin/users',
        implemented: false,
      ),
      _AdminMenu(
        icon: Icons.verified_user_outlined,
        label: 'Verifikasi Anggota Baru',
        subtitle: '$_kPendingVerif menunggu verifikasi',
        route: '/admin/verifikasi',
        badgeCount: _kPendingVerif,
        implemented: false,
      ),
      _AdminMenu(
        icon: Icons.badge_outlined,
        label: 'Assign Jabatan',
        subtitle: 'Atur role & jabatan anggota',
        route: '/admin/periode/jabatan',
        implemented: false,
      ),
    ],
  ),
  _AdminCategory(
    label: 'Open Recruitment',
    color: AppColors.secondaryContainer,
    menus: [
      _AdminMenu(
        icon: Icons.assignment_ind_outlined,
        label: 'Dashboard OR',
        subtitle: '${kApplicants.length} total pelamar',
        route: '/admin/or',
        badgeCount: _kPendingOR,
      ),
      _AdminMenu(
        icon: Icons.tune_outlined,
        label: 'Kelola Periode OR',
        subtitle: kOrPeriode.status == ORStatus.buka
            ? 'Sedang buka · ${kOrPeriode.sisaHari} hari lagi'
            : 'Periode tidak aktif',
        route: '/admin/or/kelola',
      ),
    ],
  ),
  _AdminCategory(
    label: 'Konten & Komunikasi',
    color: AppColors.tertiaryContainer,
    menus: [
      _AdminMenu(
        icon: Icons.article_outlined,
        label: 'Kelola Berita',
        subtitle: 'Buat & edit berita & pengumuman',
        route: '/admin/berita',
        implemented: false,
      ),
      _AdminMenu(
        icon: Icons.campaign_outlined,
        label: 'Kirim Pengumuman',
        subtitle: 'Broadcast ke semua anggota',
        route: '/admin/pengumuman/buat',
        implemented: false,
      ),
    ],
  ),
  _AdminCategory(
    label: 'Kegiatan & Absensi',
    color: AppColors.surfaceContainerHighest,
    menus: [
      _AdminMenu(
        icon: Icons.event_available_outlined,
        label: 'Kelola Semua Kegiatan',
        subtitle: 'Manajemen kegiatan seluruh bidang',
        route: '/admin/kegiatan',
        implemented: false,
      ),
      _AdminMenu(
        icon: Icons.how_to_reg_outlined,
        label: 'Rekap Absensi',
        subtitle: 'Riwayat absensi semua anggota',
        route: '/absensi/riwayat-sekret',
      ),
      _AdminMenu(
        icon: Icons.qr_code_2_outlined,
        label: 'Generator QR Absensi',
        subtitle: 'Buat QR untuk kegiatan',
        route: '/admin/qr-generator',
        implemented: false,
      ),
    ],
  ),
  _AdminCategory(
    label: 'Keuangan',
    color: AppColors.errorContainer,
    menus: [
      _AdminMenu(
        icon: Icons.payments_outlined,
        label: 'Uang Khas Semua Anggota',
        subtitle: 'Pantau pembayaran iuran',
        route: '/admin/uang-khas',
        implemented: false,
      ),
      _AdminMenu(
        icon: Icons.verified_outlined,
        label: 'Verifikasi Pembayaran',
        subtitle: 'Konfirmasi bukti bayar masuk',
        route: '/admin/uang-khas/verifikasi',
        implemented: false,
      ),
      _AdminMenu(
        icon: Icons.bar_chart_outlined,
        label: 'Rekap & Export Keuangan',
        subtitle: 'Laporan keuangan keseluruhan',
        route: '/admin/keuangan',
        implemented: false,
      ),
    ],
  ),
  _AdminCategory(
    label: 'Poin & Prestasi',
    color: AppColors.surfaceContainerHighest,
    menus: [
      _AdminMenu(
        icon: Icons.stars_outlined,
        label: 'Kelola Poin Semua Anggota',
        subtitle: 'Tambah / kurangi poin keaktifan',
        route: '/admin/poin',
        implemented: false,
      ),
    ],
  ),
  _AdminCategory(
    label: 'Pengaturan Sistem',
    color: AppColors.surfaceContainerHigh,
    menus: [
      _AdminMenu(
        icon: Icons.calendar_month_outlined,
        label: 'Kelola Periode Kepengurusan',
        subtitle: 'Atur masa jabatan & regenerasi',
        route: '/admin/periode',
        implemented: false,
      ),
      _AdminMenu(
        icon: Icons.receipt_long_outlined,
        label: 'Log Aktivitas Sistem',
        subtitle: 'Audit trail seluruh aksi admin',
        route: '/admin/log',
        implemented: false,
      ),
    ],
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────────────

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FloatingAppBar(title: 'Panel Admin', showBack: true),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginPage, AppSpacing.stackGap,
              AppSpacing.marginPage, 60,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Admin Identity Banner ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.innerPadding + 4,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blackCharcoal,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.blackCharcoal, width: 2),
                    boxShadow: const [AppColors.hardShadow],
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${AppSession.nama.split(' ').first}',
                          style: AppTypography.headlineSm.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              'ADMIN',
                              style: AppTypography.labelBold.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppSession.jabatan,
                            style: AppTypography.bodyMd.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ]),
                      ],
                    )),
                  ]),
                ),
                const SizedBox(height: AppSpacing.stackGap),

                // ── Quick Stats ───────────────────────────────────────────
                Row(children: [
                  _StatCard(
                    value: '$_kTotalUser',
                    label: 'Total User',
                    icon: Icons.people_outline,
                    color: AppColors.surfaceContainerLowest,
                  ),
                  const SizedBox(width: AppSpacing.gutterGrid),
                  _StatCard(
                    value: '$_kAnggotaAktif',
                    label: 'Aktif',
                    icon: Icons.verified_outlined,
                    color: AppColors.success,
                    textColor: AppColors.onSuccess,
                  ),
                  const SizedBox(width: AppSpacing.gutterGrid),
                  _StatCard(
                    value: '$_kPendingVerif',
                    label: 'Verif.',
                    icon: Icons.hourglass_top_outlined,
                    color: AppColors.secondaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.gutterGrid),
                  _StatCard(
                    value: '$_kPendingOR',
                    label: 'Pend. OR',
                    icon: Icons.assignment_late_outlined,
                    color: AppColors.errorContainer,
                  ),
                ]),
                const SizedBox(height: AppSpacing.stackGap),

                // ── Categories ────────────────────────────────────────────
                for (final cat in _kCategories) ...[
                  _CategorySection(category: cat),
                  const SizedBox(height: AppSpacing.stackGap),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.textColor,
  });
  final String value, label;
  final IconData icon;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final fg = textColor ?? AppColors.onSurface;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: const [AppColors.hardShadowSm],
        ),
        child: Column(children: [
          Icon(icon, size: 16, color: fg.withValues(alpha: 0.8)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.headlineSm.copyWith(
            fontWeight: FontWeight.w800, color: fg,
          )),
          Text(label, style: AppTypography.labelBold.copyWith(
            color: fg.withValues(alpha: 0.7), fontSize: 9,
          )),
        ]),
      ),
    );
  }
}

// ── Category Section ──────────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category});
  final _AdminCategory category;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            color: AppColors.blackCharcoal,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          category.label.toUpperCase(),
          style: AppTypography.labelBold.copyWith(
            color: AppColors.tertiary,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
      ]),
      const SizedBox(height: 8),
      const MyDivider(color: AppColors.borderSlate, height: 1),
      const SizedBox(height: 8),
      ...category.menus.map((m) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _AdminMenuTile(menu: m, accentColor: category.color),
      )),
    ]);
  }
}

// ── Menu Tile ─────────────────────────────────────────────────────────────────

class _AdminMenuTile extends StatefulWidget {
  const _AdminMenuTile({required this.menu, required this.accentColor});
  final _AdminMenu menu;
  final Color accentColor;

  @override
  State<_AdminMenuTile> createState() => _AdminMenuTileState();
}

class _AdminMenuTileState extends State<_AdminMenuTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        if (menu.implemented) {
          context.push(menu.route);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              '${menu.label} — Segera hadir',
              style: AppTypography.bodyMd.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.blackCharcoal,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            duration: const Duration(seconds: 2),
          ));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _pressed ? Matrix4.translationValues(3, 3, 0) : Matrix4.identity(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.innerPadding,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: menu.implemented
              ? AppColors.surfaceContainerLowest
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: [BoxShadow(
            color: AppColors.blackCharcoal,
            offset: _pressed ? const Offset(1, 1) : const Offset(3, 3),
            blurRadius: 0,
          )],
        ),
        child: Row(children: [
          // Accent icon box
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: menu.implemented
                  ? widget.accentColor
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
            ),
            child: Icon(
              menu.icon,
              size: 20,
              color: menu.implemented ? AppColors.blackCharcoal : AppColors.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(menu.label, style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.w700,
                color: menu.implemented ? AppColors.onSurface : AppColors.tertiary,
              )),
              const SizedBox(height: 2),
              Text(menu.subtitle, style: AppTypography.bodyMd.copyWith(
                color: AppColors.tertiary,
                fontSize: 12,
              )),
            ],
          )),
          const SizedBox(width: 8),
          if (!menu.implemented)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.borderSlate, width: 1),
              ),
              child: Text('Soon', style: AppTypography.labelBold.copyWith(
                color: AppColors.tertiary, fontSize: 10,
              )),
            )
          else if (menu.badgeCount > 0)
            Stack(children: [
              const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
              Positioned(
                right: 0, top: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text('${menu.badgeCount}', style: AppTypography.labelBold.copyWith(
                    color: Colors.white, fontSize: 8,
                  )),
                ),
              ),
            ])
          else
            const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
        ]),
      ),
    );
  }
}
