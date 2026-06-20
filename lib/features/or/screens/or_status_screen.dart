import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../or_data.dart';

class OrStatusScreen extends StatelessWidget {
  const OrStatusScreen({super.key, this.nim});
  final String? nim;

  @override
  Widget build(BuildContext context) {
    // Look up applicant by nim (if passed) or AppSession.nim (if present)
    ORApplicant? app;
    final lookupNim = nim ?? AppSession.nim;
    final index = kApplicants.indexWhere((a) => a.nim == lookupNim);
    if (index != -1) {
      app = kApplicants[index];
    }

    if (app == null) {
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
                    'Status Pendaftaran',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.marginPage),
            child: BrutalistCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.assignment_late_outlined, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Pendaftaran',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kamu belum terdaftar dalam seleksi Open Recruitment UKM POLICY periode ini.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  BrutalistButton(
                    label: 'DAFTAR SEKARANG',
                    icon: Icons.assignment_ind_outlined,
                    onPressed: () => context.pushReplacement('/or/daftar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final (bg, fg, icon, label) = _statusStyle(app.status);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FloatingAppBar(title: 'Status Pendaftaran', showBack: true),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, 60,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Status Card ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.innerPadding + 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.blackCharcoal, width: 2),
                  boxShadow: const [AppColors.hardShadow],
                ),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.blackCharcoal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 40, color: fg),
                  ),
                  const SizedBox(height: 12),
                  Text(label, style: AppTypography.headlineMd.copyWith(color: fg)),
                  const SizedBox(height: 4),
                  Text(
                    _statusSubtitle(app.status),
                    style: AppTypography.bodyMd.copyWith(
                      color: fg.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (app.catatan != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.blackCharcoal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(Icons.comment_outlined, size: 14, color: fg.withValues(alpha: 0.7)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(
                          app.catatan!,
                          style: AppTypography.bodyMd.copyWith(
                            color: fg.withValues(alpha: 0.85),
                            fontStyle: FontStyle.italic,
                          ),
                        )),
                      ]),
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // ── Ringkasan Pendaftaran ──────────────────────────────────────
              BrutalistCard(
                padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Ringkasan Pendaftaran', style: AppTypography.headlineSm),
                  const SizedBox(height: 12),
                  const MyDivider(color: AppColors.borderSlate, height: 8),
                  const SizedBox(height: 12),
                  _DataRow(label: 'Nama', value: app.nama),
                  _DataRow(label: 'NIM', value: app.nim),
                  _DataRow(label: 'Program Studi', value: app.prodi),
                  _DataRow(label: 'Angkatan', value: app.angkatan),
                  _DataRow(label: 'No. WhatsApp', value: app.noHp),
                  _DataRow(label: 'Bidang Minat', value: app.bidangMinat),
                  _DataRow(label: 'Tanggal Daftar', value: _fmtDate(app.tanggalDaftar)),
                ]),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // ── Timeline ──────────────────────────────────────────────────
              BrutalistCard(
                padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Timeline Proses', style: AppTypography.headlineSm),
                  const SizedBox(height: 16),
                  _TimelineItem(
                    icon: Icons.how_to_reg_outlined,
                    label: 'Formulir Dikirim',
                    date: _fmtDate(app.tanggalDaftar),
                    done: true,
                    isLast: false,
                  ),
                  _TimelineItem(
                    icon: Icons.manage_search_outlined,
                    label: 'Seleksi Administratif',
                    date: app.status != ApplicantStatus.pending
                        ? 'Selesai'
                        : 'Dalam Proses',
                    done: app.status != ApplicantStatus.pending,
                    isLast: false,
                  ),
                  _TimelineItem(
                    icon: app.status == ApplicantStatus.diterima
                        ? Icons.check_circle_outline
                        : app.status == ApplicantStatus.ditolak
                            ? Icons.cancel_outlined
                            : Icons.pending_outlined,
                    label: app.status == ApplicantStatus.diterima
                        ? 'Diterima sebagai Anggota'
                        : app.status == ApplicantStatus.ditolak
                            ? 'Tidak Lolos Seleksi'
                            : 'Pengumuman Hasil',
                    date: app.status == ApplicantStatus.pending ? 'Menunggu' : 'Selesai',
                    done: app.status != ApplicantStatus.pending,
                    isLast: true,
                  ),
                ]),
              ),
              const SizedBox(height: 20),

              if (app.status == ApplicantStatus.pending)
                Center(
                  child: Text(
                    'Pengumuman akan dikirim via Inbox setelah proses seleksi selesai.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (app.status == ApplicantStatus.diterima) ...[
                _GreenButton(
                  label: 'Lihat Detail Akun Saya',
                  icon: Icons.person_outline,
                  onTap: () => context.push('/menu'),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  (Color, Color, IconData, String) _statusStyle(ApplicantStatus s) => switch (s) {
    ApplicantStatus.pending => (
        AppColors.secondaryContainer,
        AppColors.onSecondaryContainer,
        Icons.hourglass_top_outlined,
        'MENUNGGU REVIEW',
      ),
    ApplicantStatus.diterima => (
        AppColors.success,
        AppColors.onSuccess,
        Icons.check_circle_outline,
        'SELAMAT, DITERIMA!',
      ),
    ApplicantStatus.ditolak => (
        AppColors.errorContainer,
        AppColors.onErrorContainer,
        Icons.cancel_outlined,
        'BELUM LOLOS',
      ),
  };

  String _statusSubtitle(ApplicantStatus s) => switch (s) {
    ApplicantStatus.pending => 'Pendaftaranmu sedang diproses oleh pengurus',
    ApplicantStatus.diterima => 'Kamu resmi menjadi Anggota UKM POLICY',
    ApplicantStatus.ditolak => 'Tetap semangat, coba lagi di periode berikutnya',
  };

  String _fmtDate(DateTime d) =>
      '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
        ),
        Expanded(child: Text(value, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.label,
    required this.date,
    required this.done,
    required this.isLast,
  });
  final IconData icon;
  final String label, date;
  final bool done, isLast;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: done ? AppColors.success : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blackCharcoal, width: 2),
          ),
          child: Icon(icon, size: 14,
            color: done ? AppColors.onSuccess : AppColors.tertiary),
        ),
        if (!isLast)
          Container(width: 2, height: 36, color: AppColors.borderSlate),
      ]),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 4),
            Text(label, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
            Text(date, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
          ]),
        ),
      ),
    ]);
  }
}

class _GreenButton extends StatefulWidget {
  const _GreenButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_GreenButton> createState() => _GreenButtonState();
}

class _GreenButtonState extends State<_GreenButton> {
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: [BoxShadow(
            color: AppColors.blackCharcoal,
            offset: _pressed ? const Offset(1, 1) : const Offset(4, 4),
            blurRadius: 0,
          )],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(widget.icon, size: 18, color: AppColors.onSuccess),
          const SizedBox(width: 8),
          Text(widget.label, style: AppTypography.bodyLg.copyWith(
            color: AppColors.onSuccess, fontWeight: FontWeight.w700,
          )),
        ]),
      ),
    );
  }
}
