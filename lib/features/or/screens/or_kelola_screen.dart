import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../or_data.dart';

class OrKelolaScreen extends StatefulWidget {
  const OrKelolaScreen({super.key});

  @override
  State<OrKelolaScreen> createState() => _OrKelolaScreenState();
}

class _OrKelolaScreenState extends State<OrKelolaScreen> {
  late bool _isManuallyOpen;
  late DateTime _tanggalBuka;
  late DateTime _tanggalTutup;
  late int _kuota;
  late String _deskripsi;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = kOrPeriode;
    _isManuallyOpen = p.isManuallyOpen;
    _tanggalBuka = p.tanggalBuka;
    _tanggalTutup = p.tanggalTutup;
    _kuota = p.kuota;
    _deskripsi = p.deskripsi;
  }

  Future<void> _pickDate({required bool isBuka}) async {
    final initial = isBuka ? _tanggalBuka : _tanggalTutup;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2026),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: AppColors.surfaceContainerLowest,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isBuka) {
        _tanggalBuka = picked;
      } else {
        _tanggalTutup = picked;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Periode berhasil diperbarui',
        style: AppTypography.bodyMd.copyWith(color: Colors.white)),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FloatingAppBar(title: 'Kelola Periode OR', showBack: true),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginPage, AppSpacing.stackGap,
              AppSpacing.marginPage, 40,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Toggle Buka/Tutup ─────────────────────────────────────
                BrutalistCard(
                  padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHead(label: 'STATUS PENDAFTARAN'),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          _isManuallyOpen ? 'Pendaftaran Dibuka' : 'Pendaftaran Ditutup',
                          style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isManuallyOpen
                              ? 'User Public dapat mendaftar'
                              : 'Tidak ada yang bisa mendaftar',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                        ),
                      ])),
                      _BrutalistToggle(
                        value: _isManuallyOpen,
                        onChanged: (v) => setState(() => _isManuallyOpen = v),
                      ),
                    ]),
                    if (_isManuallyOpen) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                        ),
                        child: Row(children: [
                          const Icon(Icons.info_outline, size: 14, color: AppColors.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                            'Pendaftaran akan otomatis tutup setelah Tanggal Tutup.',
                            style: AppTypography.labelBold.copyWith(
                              color: AppColors.onPrimaryContainer, fontSize: 11,
                            ),
                          )),
                        ]),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: AppSpacing.gutterGrid),

                // ── Tanggal ───────────────────────────────────────────────
                BrutalistCard(
                  padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHead(label: 'PERIODE WAKTU'),
                    const SizedBox(height: 14),
                    _DateField(
                      label: 'Tanggal Buka',
                      date: _tanggalBuka,
                      onTap: () => _pickDate(isBuka: true),
                    ),
                    const SizedBox(height: 10),
                    _DateField(
                      label: 'Tanggal Tutup',
                      date: _tanggalTutup,
                      onTap: () => _pickDate(isBuka: false),
                    ),
                    if (_tanggalTutup.isBefore(_tanggalBuka)) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal tutup harus setelah tanggal buka',
                        style: AppTypography.labelBold.copyWith(color: AppColors.error),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: AppSpacing.gutterGrid),

                // ── Kuota ─────────────────────────────────────────────────
                BrutalistCard(
                  padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHead(label: 'KUOTA ANGGOTA'),
                    const SizedBox(height: 14),
                    Row(children: [
                      _KuotaButton(
                        icon: Icons.remove,
                        onTap: _kuota > 1
                            ? () => setState(() => _kuota--)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(children: [
                        Text(
                          '$_kuota',
                          style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                        Text('anggota', style: AppTypography.labelBold.copyWith(
                          color: AppColors.tertiary,
                        )),
                      ])),
                      const SizedBox(width: 16),
                      _KuotaButton(
                        icon: Icons.add,
                        onTap: _kuota < 200
                            ? () => setState(() => _kuota++)
                            : null,
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Center(child: Text(
                      '${kApplicants.where((a) => a.status == ApplicantStatus.diterima).length} sudah diterima',
                      style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
                    )),
                  ]),
                ),
                const SizedBox(height: AppSpacing.gutterGrid),

                // ── Deskripsi ─────────────────────────────────────────────
                BrutalistCard(
                  padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _SectionHead(label: 'DESKRIPSI'),
                    const SizedBox(height: 14),
                    TextFormField(
                      initialValue: _deskripsi,
                      onChanged: (v) => _deskripsi = v,
                      maxLines: 5,
                      style: AppTypography.bodyMd.copyWith(height: 1.6),
                      decoration: InputDecoration(
                        hintText: 'Deskripsi Open Recruitment...',
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
                ),
                const SizedBox(height: AppSpacing.stackGap),

                // ── Save Button ───────────────────────────────────────────
                _SaveButton(saving: _saving, onTap: _save),
                const SizedBox(height: 12),

                // ── Danger Zone ───────────────────────────────────────────
                BrutalistCard(
                  padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.warning_amber_outlined, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Danger Zone', style: AppTypography.labelBold.copyWith(
                        color: AppColors.error,
                      )),
                    ]),
                    const SizedBox(height: 10),
                    const MyDivider(color: AppColors.error, height: 1),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _confirmReset(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                          border: Border.all(color: AppColors.error, width: 2),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.delete_sweep_outlined, size: 16, color: AppColors.onErrorContainer),
                          const SizedBox(width: 8),
                          Text('Reset Semua Data Pelamar',
                            style: AppTypography.labelBold.copyWith(
                              color: AppColors.onErrorContainer,
                            )),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.blackCharcoal, width: 2),
        ),
        title: Text('Reset Data Pelamar?', style: AppTypography.headlineSm),
        content: Text(
          'Semua data pelamar akan dihapus permanen. Tindakan ini tidak dapat diurungkan.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Batal', style: AppTypography.labelBold),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Data pelamar direset',
                  style: AppTypography.bodyMd.copyWith(color: Colors.white)),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              ));
            },
            child: Text('Hapus', style: AppTypography.labelBold.copyWith(
              color: AppColors.error,
            )),
          ),
        ],
      ),
    );
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

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.date, required this.onTap});
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  static const _bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: const [AppColors.hardShadowSm],
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.tertiary),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTypography.labelBold.copyWith(
              color: AppColors.tertiary, fontSize: 10,
            )),
            const SizedBox(height: 2),
            Text(
              '${date.day} ${_bulan[date.month - 1]} ${date.year}',
              style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
            ),
          ])),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
        ]),
      ),
    );
  }
}

class _KuotaButton extends StatelessWidget {
  const _KuotaButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surfaceContainerLowest : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(
            color: enabled ? AppColors.blackCharcoal : AppColors.borderSlate,
            width: 2,
          ),
          boxShadow: enabled ? const [AppColors.hardShadowSm] : null,
        ),
        child: Icon(icon, size: 20,
          color: enabled ? AppColors.onSurface : AppColors.tertiary),
      ),
    );
  }
}

class _BrutalistToggle extends StatelessWidget {
  const _BrutalistToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: const [AppColors.hardShadowSm],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: value ? AppColors.onPrimary : AppColors.tertiary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton({required this.saving, required this.onTap});
  final bool saving;
  final VoidCallback onTap;

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    if (widget.saving) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _pressed ? Matrix4.translationValues(3, 3, 0) : Matrix4.identity(),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: [BoxShadow(
            color: AppColors.blackCharcoal,
            offset: _pressed ? const Offset(1, 1) : const Offset(4, 4),
            blurRadius: 0,
          )],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.save_outlined, size: 18, color: AppColors.onPrimary),
          const SizedBox(width: 8),
          Text('Simpan Perubahan', style: AppTypography.bodyLg.copyWith(
            color: AppColors.onPrimary, fontWeight: FontWeight.w700,
          )),
        ]),
      ),
    );
  }
}
