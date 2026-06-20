import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../or_data.dart';

class OrScreen extends StatelessWidget {
  const OrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final periode = kOrPeriode;
    final status = periode.status;
    final isOpen = status == ORStatus.buka;
    final accepted = kApplicants.where((a) => a.status == ApplicantStatus.diterima).length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FloatingAppBar(title: 'Open Recruitment', showBack: true),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, 100,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Status Banner ─────────────────────────────────────────────
              _StatusBanner(status: status, periode: periode),
              const SizedBox(height: AppSpacing.stackGap),

              // ── Info Card ─────────────────────────────────────────────────
              BrutalistCard(
                padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(periode.nama, style: AppTypography.headlineSm),
                  const SizedBox(height: 12),
                  const MyDivider(color: AppColors.borderSlate, height: 8),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Tanggal Buka',
                    value: _fmtDate(periode.tanggalBuka),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.event_busy_outlined,
                    label: 'Tanggal Tutup',
                    value: _fmtDate(periode.tanggalTutup),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.groups_outlined,
                    label: 'Kuota',
                    value: '${periode.kuota} anggota',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.check_circle_outline,
                    label: 'Sudah Diterima',
                    value: '$accepted pendaftar',
                  ),
                  if (isOpen) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.timer_outlined,
                      label: 'Sisa Waktu',
                      value: '${periode.sisaHari} hari lagi',
                      valueColor: periode.sisaHari <= 3
                          ? AppColors.error
                          : AppColors.secondary,
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // ── Deskripsi ─────────────────────────────────────────────────
              BrutalistCard(
                padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.tertiary),
                    const SizedBox(width: 6),
                    Text('Tentang OR', style: AppTypography.labelBold.copyWith(
                      color: AppColors.tertiary,
                    )),
                  ]),
                  const SizedBox(height: 10),
                  Text(periode.deskripsi, style: AppTypography.bodyMd.copyWith(
                    height: 1.6,
                  )),
                ]),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // ── Bidang Tersedia ───────────────────────────────────────────
              BrutalistCard(
                padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.category_outlined, size: 16, color: AppColors.tertiary),
                    const SizedBox(width: 6),
                    Text('Bidang yang Tersedia', style: AppTypography.labelBold.copyWith(
                      color: AppColors.tertiary,
                    )),
                  ]),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kBidangList.map((b) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                        boxShadow: const [AppColors.hardShadowSm],
                      ),
                      child: Text(b, style: AppTypography.labelBold.copyWith(
                        color: AppColors.onSecondaryContainer,
                      )),
                    )).toList(),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // ── Actions ───────────────────────────────────────────────────
              if (isOpen) ...[
                _ActionButton(
                  label: 'Daftar Sekarang',
                  icon: Icons.edit_note,
                  color: AppColors.primaryContainer,
                  textColor: AppColors.onPrimaryContainer,
                  onTap: () => context.push('/or/daftar'),
                ),
                const SizedBox(height: 10),
              ],
              _ActionButton(
                label: 'Cek Status Pendaftaran',
                icon: Icons.search,
                color: AppColors.surfaceContainerLowest,
                textColor: AppColors.onSurface,
                onTap: () => context.push('/or/status'),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
}

// ── Status Banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status, required this.periode});
  final ORStatus status;
  final ORPeriode periode;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon, label, sub) = switch (status) {
      ORStatus.buka => (
          AppColors.primaryContainer,
          AppColors.onPrimaryContainer,
          Icons.lock_open_outlined,
          'PENDAFTARAN DIBUKA',
          'Segera daftarkan dirimu!',
        ),
      ORStatus.belumBuka => (
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer,
          Icons.schedule_outlined,
          'BELUM DIBUKA',
          'Pendaftaran akan segera dibuka',
        ),
      ORStatus.ditutup => (
          AppColors.surfaceContainerHigh,
          AppColors.onSurface,
          Icons.lock_outlined,
          'PENDAFTARAN DITUTUP',
          'Nantikan periode OR berikutnya',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.innerPadding + 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadow],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.blackCharcoal.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: fg),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTypography.headlineSm.copyWith(color: fg)),
          const SizedBox(height: 2),
          Text(sub, style: AppTypography.bodyMd.copyWith(color: fg.withValues(alpha: 0.8))),
        ])),
      ]),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label, value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.tertiary),
      const SizedBox(width: 8),
      Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
      const Spacer(),
      Text(value, style: AppTypography.labelBold.copyWith(
        color: valueColor ?? AppColors.onSurface,
      )),
    ]);
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color, textColor;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _pressed ? Matrix4.translationValues(3, 3, 0) : Matrix4.identity(),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackCharcoal,
              offset: _pressed ? const Offset(1, 1) : const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(widget.icon, size: 20, color: widget.textColor),
          const SizedBox(width: 10),
          Text(widget.label, style: AppTypography.bodyLg.copyWith(
            color: widget.textColor,
            fontWeight: FontWeight.w700,
          )),
        ]),
      ),
    );
  }
}
