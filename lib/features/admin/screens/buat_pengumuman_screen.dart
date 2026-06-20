import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/brutalist_card.dart';

class BuatPengumumanScreen extends StatefulWidget {
  const BuatPengumumanScreen({super.key});

  @override
  State<BuatPengumumanScreen> createState() => _BuatPengumumanScreenState();
}

class _BuatPengumumanScreenState extends State<BuatPengumumanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _actionLabelCtrl = TextEditingController();
  final _actionRouteCtrl = TextEditingController();

  String _selectedCat = 'PENTING';
  bool _showActionCard = false;
  bool _sending = false;

  final List<String> _categories = [
    'PENTING',
    'KEGIATAN',
    'KEUANGAN',
    'REKRUTMEN',
    'PRESTASI',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _actionLabelCtrl.dispose();
    _actionRouteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pengumuman berhasil disebarkan!',
            style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
    context.pop();
  }

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
                  'Buat Pengumuman',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category
                const _FieldLabel(label: 'KATEGORI PENGUMUMAN'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCat,
                  onChanged: (v) => setState(() => _selectedCat = v ?? 'PENTING'),
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.campaign_outlined, size: 20),
                  ),
                  items: _categories.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.stackGap),

                // Judul
                const _FieldLabel(label: 'JUDUL PENGUMUMAN'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleCtrl,
                  style: AppTypography.bodyMd,
                  decoration: const InputDecoration(
                    hintText: 'Tulis judul pengumuman...',
                    prefixIcon: Icon(Icons.title, size: 20),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Judul pengumuman wajib diisi' : null,
                ),
                const SizedBox(height: AppSpacing.stackGap),

                // Konten
                const _FieldLabel(label: 'KONTEN PENGUMUMAN'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _contentCtrl,
                  maxLines: 5,
                  style: AppTypography.bodyMd,
                  decoration: const InputDecoration(
                    hintText: 'Tulis isi pengumuman lengkap...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 80),
                      child: Icon(Icons.description_outlined, size: 20),
                    ),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Konten pengumuman wajib diisi' : null,
                ),
                const SizedBox(height: AppSpacing.stackGap),

                // Action Toggle Card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TAMBAHKAN TOMBOL AKSI',
                      style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
                    ),
                    Switch(
                      value: _showActionCard,
                      activeThumbColor: AppColors.primaryContainer,
                      activeTrackColor: AppColors.primaryContainer.withValues(alpha: 0.4),
                      onChanged: (v) => setState(() => _showActionCard = v),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                if (_showActionCard) ...[
                  BrutalistCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppColors.surfaceContainerLowest,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('TOMBOL UTAMA', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _actionLabelCtrl,
                          style: AppTypography.bodyMd,
                          decoration: const InputDecoration(
                            hintText: 'Label tombol (Contoh: "Lihat Rapat")',
                            prefixIcon: Icon(Icons.touch_app_outlined, size: 18),
                          ),
                          validator: (v) => _showActionCard && (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: AppSpacing.stackGap),
                        Text('ROUTE TUJUAN', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _actionRouteCtrl,
                          style: AppTypography.bodyMd,
                          decoration: const InputDecoration(
                            hintText: 'Route aplikasi (Contoh: "/kegiatan")',
                            prefixIcon: Icon(Icons.link_outlined, size: 18),
                          ),
                          validator: (v) => _showActionCard && (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // Submit Button
                _sending
                    ? const Center(child: CircularProgressIndicator())
                    : BrutalistButton(
                        label: 'KIRIM SEKARANG',
                        icon: Icons.send_outlined,
                        onPressed: _submit,
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.labelBold.copyWith(
        color: AppColors.onSurface,
        letterSpacing: 0.5,
      ),
    );
  }
}
