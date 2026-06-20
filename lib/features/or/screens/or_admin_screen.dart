import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/models/or_model.dart';
import '../../../data/repositories/or_repository.dart';

class OrAdminScreen extends StatefulWidget {
  const OrAdminScreen({super.key});

  @override
  State<OrAdminScreen> createState() => _OrAdminScreenState();
}

class _OrAdminScreenState extends State<OrAdminScreen> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final orRepo = context.watch<ORRepository>();
    final periode = orRepo.orPeriode;
    final isOpen = periode.status == ORStatus.buka;
    final applicants = orRepo.applicants;

    final totalPending = applicants.where((a) => a.status == ApplicantStatus.pending).length;
    final totalDiterima = applicants.where((a) => a.status == ApplicantStatus.diterima).length;
    final totalDitolak = applicants.where((a) => a.status == ApplicantStatus.ditolak).length;

    final filtered = applicants.where((a) {
      if (_filter == 'Semua') return true;
      return switch (_filter) {
        'Pending' => a.status == ApplicantStatus.pending,
        'Diterima' => a.status == ApplicantStatus.diterima,
        'Ditolak' => a.status == ApplicantStatus.ditolak,
        _ => true,
      };
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FloatingAppBar(
            title: 'Dashboard OR',
            showBack: true,
            trailing: GestureDetector(
              onTap: () => context.push('/admin/or/kelola'),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                  border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.settings_outlined, size: 14, color: AppColors.onSurface),
                  const SizedBox(width: 4),
                  Text('Kelola', style: AppTypography.labelBold),
                ]),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, 60,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── OR Status Banner ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isOpen ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  border: Border.all(color: AppColors.blackCharcoal, width: 2),
                  boxShadow: const [AppColors.hardShadowSm],
                ),
                child: Row(children: [
                  Icon(
                    isOpen ? Icons.lock_open_outlined : Icons.lock_outlined,
                    size: 16,
                    color: isOpen ? AppColors.onPrimaryContainer : AppColors.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    isOpen
                        ? '${periode.nama} — SEDANG BUKA (${periode.sisaHari} hari lagi)'
                        : '${periode.nama} — DITUTUP',
                    style: AppTypography.labelBold.copyWith(
                      color: isOpen ? AppColors.onPrimaryContainer : AppColors.tertiary,
                    ),
                  )),
                ]),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // ── Stats ─────────────────────────────────────────────────────
              Row(children: [
                _StatBox(
                  value: '${applicants.length}',
                  label: 'Total',
                  color: AppColors.surfaceContainerHigh,
                ),
                const SizedBox(width: AppSpacing.gutterGrid),
                _StatBox(
                  value: '$totalPending',
                  label: 'Pending',
                  color: AppColors.secondaryContainer,
                ),
                const SizedBox(width: AppSpacing.gutterGrid),
                _StatBox(
                  value: '$totalDiterima',
                  label: 'Diterima',
                  color: AppColors.success,
                  textColor: AppColors.onSuccess,
                ),
                const SizedBox(width: AppSpacing.gutterGrid),
                _StatBox(
                  value: '$totalDitolak',
                  label: 'Ditolak',
                  color: AppColors.errorContainer,
                ),
              ]),
              const SizedBox(height: AppSpacing.stackGap),

              // ── Filter ────────────────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Pending', 'Diterima', 'Ditolak'].map((f) {
                    final active = _filter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                          border: Border.all(color: AppColors.blackCharcoal, width: 2),
                          boxShadow: [BoxShadow(
                            color: AppColors.blackCharcoal,
                            offset: active ? const Offset(2, 2) : const Offset(3, 3),
                            blurRadius: 0,
                          )],
                        ),
                        child: Text(f, style: AppTypography.labelBold.copyWith(
                          color: active ? AppColors.onPrimaryContainer : AppColors.onSurface,
                        )),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // ── List Pelamar ──────────────────────────────────────────────
              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text('Tidak ada data', style: AppTypography.bodyLg.copyWith(
                      color: AppColors.tertiary,
                    )),
                  ),
                )
              else
                ...filtered.map((app) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.gutterGrid),
                  child: BrutalistCard(
                    onTap: () => context.push('/admin/or/${app.id}'),
                    padding: const EdgeInsets.all(AppSpacing.innerPadding + 2),
                    child: Row(children: [
                      // Avatar placeholder
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.blackCharcoal, width: 2),
                        ),
                        child: Center(child: Text(
                          app.nama.substring(0, 1),
                          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(app.nama, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${app.prodi} · ${app.angkatan}',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                        const SizedBox(height: 4),
                        Row(children: [
                          _BidangChip(label: app.bidangMinat),
                        ]),
                      ])),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        _StatusChip(status: app.status),
                        const SizedBox(height: 4),
                        Text(_fmtDate(app.tanggalDaftar),
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.tertiary, fontSize: 10,
                          )),
                      ]),
                    ]),
                  ),
                )),

              const SizedBox(height: AppSpacing.stackGap),
              const MyDivider(color: AppColors.borderSlate, height: 1),
              const SizedBox(height: 12),
              Center(child: Text(
                'Kuota: $totalDiterima/${periode.kuota} telah terisi',
                style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
              )),
            ]),
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
    this.textColor,
  });
  final String value, label;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final fg = textColor ?? AppColors.onSurface;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: const [AppColors.hardShadowSm],
        ),
        child: Column(children: [
          Text(value, style: AppTypography.headlineSm.copyWith(
            fontWeight: FontWeight.w800, color: fg,
          )),
          Text(label, style: AppTypography.labelBold.copyWith(
            color: fg.withValues(alpha: 0.75), fontSize: 10,
          )),
        ]),
      ),
    );
  }
}

class _BidangChip extends StatelessWidget {
  const _BidangChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1),
      ),
      child: Text(label, style: AppTypography.labelBold.copyWith(
        color: AppColors.onSecondaryContainer, fontSize: 10,
      )),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final ApplicantStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      ApplicantStatus.pending => (AppColors.secondaryContainer, AppColors.onSecondaryContainer, 'Pending'),
      ApplicantStatus.diterima => (AppColors.success, AppColors.onSuccess, 'Diterima'),
      ApplicantStatus.ditolak => (AppColors.errorContainer, AppColors.onErrorContainer, 'Ditolak'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Text(label, style: AppTypography.labelBold.copyWith(color: fg, fontSize: 10)),
    );
  }
}
