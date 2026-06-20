import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/models/or_model.dart';
import '../../../data/repositories/or_repository.dart';

class OrDetailScreen extends StatefulWidget {
  const OrDetailScreen({super.key, required this.id});
  final String id;

  @override
  State<OrDetailScreen> createState() => _OrDetailScreenState();
}

class _OrDetailScreenState extends State<OrDetailScreen> {
  late ApplicantStatus _status;
  final _catatanCtrl = TextEditingController();
  bool _saving = false;

  ORApplicantModel get _app {
    final orRepo = context.read<ORRepository>();
    return orRepo.applicants.firstWhere((a) => a.id == widget.id);
  }

  @override
  void initState() {
    super.initState();
    final app = context.read<ORRepository>().applicants.firstWhere((a) => a.id == widget.id);
    _status = app.status;
    _catatanCtrl.text = app.catatan ?? '';
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveDecision(ApplicantStatus newStatus) async {
    setState(() {
      _saving = true;
      _status = newStatus;
    });
    final orRepo = context.read<ORRepository>();
    orRepo.reviewApplicant(widget.id, newStatus, catatan: _catatanCtrl.text);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        newStatus == ApplicantStatus.diterima
            ? '${_app.nama} berhasil diterima'
            : '${_app.nama} ditolak',
        style: AppTypography.bodyMd.copyWith(color: Colors.white),
      ),
      backgroundColor: newStatus == ApplicantStatus.diterima
          ? AppColors.success
          : AppColors.error,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Watch applicant state
    final orRepo = context.watch<ORRepository>();
    final app = orRepo.applicants.firstWhere((a) => a.id == widget.id);
    final isPending = _status == ApplicantStatus.pending;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FloatingAppBar(title: 'Detail Pelamar', showBack: true),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginPage, AppSpacing.stackGap,
              AppSpacing.marginPage, 40,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Header ────────────────────────────────────────────────
                BrutalistCard(
                  padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                  child: Row(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.blackCharcoal, width: 2.5),
                        boxShadow: const [AppColors.hardShadowSm],
                      ),
                      child: Center(child: Text(
                        app.nama.substring(0, 1),
                        style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w800),
                      )),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(app.nama, style: AppTypography.headlineSm),
                      Text('${app.prodi} · ${app.angkatan}',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                      const SizedBox(height: 6),
                      _StatusChip(status: _status),
                    ])),
                  ]),
                ),
                const SizedBox(height: AppSpacing.gutterGrid),

                // ── Data Diri ─────────────────────────────────────────────
                BrutalistCard(
                  padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHead(label: 'DATA DIRI'),
                    const SizedBox(height: 10),
                    _Row(label: 'NIM', value: app.nim),
                    _Row(label: 'Program Studi', value: app.prodi),
                    _Row(label: 'Angkatan', value: app.angkatan),
                    _Row(label: 'No. WhatsApp', value: app.noHp),
                    _Row(label: 'Bidang Minat', value: app.bidangMinat),
                    _Row(label: 'Tanggal Daftar', value: _fmtDate(app.tanggalDaftar)),
                  ]),
                ),
                const SizedBox(height: AppSpacing.gutterGrid),

                // ── Motivasi ──────────────────────────────────────────────
                BrutalistCard(
                  padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHead(label: 'MOTIVASI'),
                    const SizedBox(height: 10),
                    Text(app.motivasi, style: AppTypography.bodyMd.copyWith(height: 1.6)),
                  ]),
                ),
                const SizedBox(height: AppSpacing.gutterGrid),

                // ── Pengalaman ────────────────────────────────────────────
                BrutalistCard(
                  padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHead(label: 'PENGALAMAN ORGANISASI'),
                    const SizedBox(height: 10),
                    Text(app.pengalamanOrg, style: AppTypography.bodyMd.copyWith(height: 1.6)),
                  ]),
                ),
                const SizedBox(height: AppSpacing.stackGap),

                // ── Catatan Admin ─────────────────────────────────────────
                if (!isPending) ...[
                  BrutalistCard(
                    padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _SectionHead(label: 'CATATAN KEPUTUSAN'),
                      const SizedBox(height: 10),
                      Text(
                        app.catatan ?? '-',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.tertiary, fontStyle: FontStyle.italic,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  _ResetButton(
                    onTap: () {
                      setState(() => _status = ApplicantStatus.pending);
                      context.read<ORRepository>().reviewApplicant(widget.id, ApplicantStatus.pending);
                    },
                  ),
                ],

                if (isPending) ...[
                  // Catatan input
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Catatan (opsional)',
                      style: AppTypography.labelBold),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _catatanCtrl,
                      maxLines: 2,
                      style: AppTypography.bodyMd,
                      decoration: InputDecoration(
                        hintText: 'Tulis catatan untuk pelamar...',
                        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                          borderSide: const BorderSide(color: AppColors.blackCharcoal, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                          borderSide: const BorderSide(color: AppColors.blackCharcoal, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Approve / Reject
                  if (_saving)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(children: [
                      Expanded(
                        child: _DecisionButton(
                          label: 'Tolak',
                          icon: Icons.close,
                          color: AppColors.errorContainer,
                          textColor: AppColors.onErrorContainer,
                          onTap: () => _saveDecision(ApplicantStatus.ditolak),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DecisionButton(
                          label: 'Terima',
                          icon: Icons.check,
                          color: AppColors.success,
                          textColor: AppColors.onSuccess,
                          onTap: () => _saveDecision(ApplicantStatus.diterima),
                        ),
                      ),
                    ]),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTypography.labelBold.copyWith(
        color: AppColors.tertiary, fontSize: 10, letterSpacing: 1.5,
      )),
      const SizedBox(height: 8),
      const MyDivider(color: AppColors.borderSlate, height: 1),
    ],
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 130,
        child: Text(label, style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
      ),
      Expanded(child: Text(value, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600))),
    ]),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final ApplicantStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      ApplicantStatus.pending  => (AppColors.secondaryContainer, AppColors.onSecondaryContainer, 'Pending'),
      ApplicantStatus.diterima => (AppColors.success, AppColors.onSuccess, 'Diterima'),
      ApplicantStatus.ditolak  => (AppColors.errorContainer, AppColors.onErrorContainer, 'Ditolak'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Text(label, style: AppTypography.labelBold.copyWith(color: fg)),
    );
  }
}

class _DecisionButton extends StatefulWidget {
  const _DecisionButton({
    required this.label, required this.icon,
    required this.color, required this.textColor, required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color, textColor;
  final VoidCallback onTap;

  @override
  State<_DecisionButton> createState() => _DecisionButtonState();
}

class _DecisionButtonState extends State<_DecisionButton> {
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: [BoxShadow(
            color: AppColors.blackCharcoal,
            offset: _pressed ? const Offset(1, 1) : const Offset(3, 3),
            blurRadius: 0,
          )],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(widget.icon, size: 18, color: widget.textColor),
          const SizedBox(width: 6),
          Text(widget.label, style: AppTypography.bodyLg.copyWith(
            color: widget.textColor, fontWeight: FontWeight.w700,
          )),
        ]),
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.refresh, size: 14, color: AppColors.tertiary),
          const SizedBox(width: 6),
          Text('Ubah Keputusan', style: AppTypography.labelBold.copyWith(
            color: AppColors.tertiary,
            decoration: TextDecoration.underline,
          )),
        ]),
      ),
    );
  }
}
