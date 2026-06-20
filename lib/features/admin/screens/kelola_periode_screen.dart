import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';

class _LocalPeriod {
  _LocalPeriod({
    required this.id,
    required this.nama,
    required this.tahun,
    required this.aktif,
  });
  final String id;
  final String nama;
  final String tahun;
  bool aktif;
}

class KelolaPeriodeScreen extends StatefulWidget {
  const KelolaPeriodeScreen({super.key});

  @override
  State<KelolaPeriodeScreen> createState() => _KelolaPeriodeScreenState();
}

class _KelolaPeriodeScreenState extends State<KelolaPeriodeScreen> {
  late List<_LocalPeriod> _periods;

  @override
  void initState() {
    super.initState();
    _periods = [
      _LocalPeriod(id: '1', nama: 'Periode 2024 / 2025', tahun: '2024', aktif: false),
      _LocalPeriod(id: '2', nama: 'Periode 2025 / 2026', tahun: '2025', aktif: true),
      _LocalPeriod(id: '3', nama: 'Periode 2026 / 2027', tahun: '2026', aktif: false),
    ];
  }

  void _setActive(String id) {
    setState(() {
      for (final p in _periods) {
        p.aktif = (p.id == id);
      }
    });
    final activePeriod = _periods.firstWhere((p) => p.id == id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${activePeriod.nama} kini diset sebagai Periode Aktif!',
          style: AppTypography.bodyMd.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.blackCharcoal, width: 2.5),
          ),
          backgroundColor: AppColors.surface,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Buat Periode Baru', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: AppColors.tertiary),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MyDivider(color: AppColors.borderSlate, height: 16),
                
                // Nama
                Text('NAMA PERIODE', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  style: AppTypography.bodyMd,
                  decoration: const InputDecoration(hintText: 'Contoh: Periode 2027 / 2028'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama periode wajib diisi' : null,
                ),
                const SizedBox(height: AppSpacing.stackGap),

                // Tahun
                Text('TAHUN MULAI', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: yearCtrl,
                  keyboardType: TextInputType.number,
                  style: AppTypography.bodyMd,
                  decoration: const InputDecoration(hintText: 'Contoh: 2027'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Tahun wajib diisi' : null,
                ),
                const SizedBox(height: 24),

                BrutalistButton(
                  label: 'BUAT PERIODE',
                  icon: Icons.check,
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    setState(() {
                      _periods.add(_LocalPeriod(
                        id: '${_periods.length + 1}',
                        nama: nameCtrl.text,
                        tahun: yearCtrl.text,
                        aktif: false,
                      ));
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Periode baru berhasil dibuat!', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(AppSpacing.marginPage),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  'Periode Kepengurusan',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: const BorderSide(color: AppColors.blackCharcoal, width: 2),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: Text('Tambah Periode', style: AppTypography.labelBold.copyWith(fontSize: 12)),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          itemCount: _periods.length,
          itemBuilder: (context, i) {
            final p = _periods[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
              child: BrutalistCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.nama,
                            style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tahun Mulai: ${p.tahun}',
                            style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.aktif ? AppColors.success : AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                            ),
                            child: Text(
                              p.aktif ? 'AKTIF' : 'TIDAK AKTIF',
                              style: AppTypography.labelBold.copyWith(
                                color: p.aktif ? Colors.white : AppColors.tertiary,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Toggle Switch (only if not already active)
                    if (!p.aktif)
                      BrutalistButton(
                        label: 'AKTIFKAN',
                        fullWidth: false,
                        onPressed: () => _setActive(p.id),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
