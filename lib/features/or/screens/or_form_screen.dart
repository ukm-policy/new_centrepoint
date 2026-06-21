import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/models/or_model.dart';
import '../../../data/repositories/or_repository.dart';

class OrFormScreen extends StatefulWidget {
  const OrFormScreen({super.key});

  @override
  State<OrFormScreen> createState() => _OrFormScreenState();
}

class _OrFormScreenState extends State<OrFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _prodiCtrl = TextEditingController();
  final _angkatanCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _motivasiCtrl = TextEditingController();
  final _pengalamanCtrl = TextEditingController();

  String? _selectedBidang;
  bool _submitting = false;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _prodiCtrl.dispose();
    _angkatanCtrl.dispose();
    _noHpCtrl.dispose();
    _motivasiCtrl.dispose();
    _pengalamanCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _submitting = false);

    final orRepo = context.read<ORRepository>();
    // Insert new applicant into repository
    final newApp = ORApplicantModel(
      id: 'app-${orRepo.applicants.length + 1}',
      periodeId: orRepo.orPeriode.id,
      nama: _namaCtrl.text,
      nim: _nimCtrl.text,
      prodi: _prodiCtrl.text,
      angkatan: _angkatanCtrl.text,
      noHp: _noHpCtrl.text,
      bidangMinat: _selectedBidang ?? '',
      motivasi: _motivasiCtrl.text,
      pengalamanOrg: _pengalamanCtrl.text,
      status: ApplicantStatus.pending,
      tanggalDaftar: DateTime.now(),
    );
    orRepo.addApplicant(newApp);

    context.pushReplacement('/or/status', extra: _nimCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final orRepo = context.watch<ORRepository>();
    final listBidang = orRepo.orPeriode.bidangTersedia;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FloatingAppBar(title: 'Formulir Pendaftaran', showBack: true),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, 40,
          ),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Periode info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                    border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.onSecondaryContainer),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      orRepo.orPeriode.nama,
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.onSecondaryContainer,
                      ),
                    )),
                  ]),
                ),
                const SizedBox(height: 20),

                _SectionLabel(label: 'DATA DIRI'),
                const SizedBox(height: 12),

                _Field(
                  controller: _namaCtrl,
                  label: 'Nama Lengkap',
                  hint: 'Sesuai KTM',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _Field(
                    controller: _nimCtrl,
                    label: 'NIM',
                    hint: '202301...',
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _Field(
                    controller: _angkatanCtrl,
                    label: 'Angkatan',
                    hint: '2023',
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  )),
                ]),
                const SizedBox(height: 12),
                _Field(
                  controller: _prodiCtrl,
                  label: 'Program Studi',
                  hint: 'D4 Sarjana Terapan Teknik Informatika',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _noHpCtrl,
                  label: 'No. WhatsApp',
                  hint: '08xxxxxxxxxx',
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 20),

                const MyDivider(color: AppColors.borderSlate, height: 1),
                const SizedBox(height: 20),

                _SectionLabel(label: 'MINAT & MOTIVASI'),
                const SizedBox(height: 12),

                // Bidang dropdown
                _DropdownField(
                  label: 'Bidang yang Diminati',
                  value: _selectedBidang,
                  items: listBidang,
                  onChanged: (v) => setState(() => _selectedBidang = v),
                  validator: (v) => v == null ? 'Pilih bidang minat' : null,
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _motivasiCtrl,
                  label: 'Motivasi Bergabung',
                  hint: 'Ceritakan motivasimu bergabung di UKM POLICY...',
                  maxLines: 4,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                    if (v.trim().length < 30) return 'Minimal 30 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _pengalamanCtrl,
                  label: 'Pengalaman Organisasi',
                  hint: 'Tuliskan pengalaman organisasi sebelumnya (isi "-" jika belum ada)',
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 28),

                // Submit button
                _SubmitButton(
                  loading: _submitting,
                  onTap: _submit,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Data yang kamu kirim akan diverifikasi oleh pengurus.',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTypography.labelBold.copyWith(
      color: AppColors.tertiary,
      letterSpacing: 1.5,
      fontSize: 10,
    ));
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });
  final TextEditingController controller;
  final String label, hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.labelBold),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: AppTypography.bodyLg,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyLg.copyWith(color: AppColors.tertiary),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
      ),
    ]);
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.labelBold),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: onChanged,
        validator: validator,
        style: AppTypography.bodyLg.copyWith(color: AppColors.onSurface),
        decoration: InputDecoration(
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        hint: Text('Pilih bidang', style: AppTypography.bodyLg.copyWith(
          color: AppColors.tertiary,
        )),
        items: items.map((b) => DropdownMenuItem(
          value: b,
          child: Text(b),
        )).toList(),
      ),
    ]);
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.loading ? null : widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _pressed ? Matrix4.translationValues(3, 3, 0) : Matrix4.identity(),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
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
        child: Center(
          child: widget.loading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onPrimaryContainer,
                  ),
                )
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.send_outlined, size: 18, color: AppColors.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text('Kirim Pendaftaran', style: AppTypography.bodyLg.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  )),
                ]),
        ),
      ),
    );
  }
}
