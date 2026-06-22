import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/repositories/periode_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../../data/models/periode_model.dart';

class KelolaPeriodeScreen extends StatelessWidget {
  const KelolaPeriodeScreen({super.key});

  void _setActive(BuildContext context, String id, String namaPeriode) {
    context.read<PeriodeRepository>().setActivePeriode(id);
    context.read<AuditLogRepository>().logAction(
      aksi: 'Mengaktifkan periode: $namaPeriode',
      tipe: 'Sistem',
      entityId: id,
      entityType: 'periode',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$namaPeriode kini diset sebagai Periode Aktif!',
          style: AppTypography.bodyMd.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
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
                onTap: () => Navigator.pop(dialogContext),
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

                Text('NAMA PERIODE', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  style: AppTypography.bodyMd,
                  decoration: const InputDecoration(hintText: 'Contoh: Periode 2027 / 2028'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Nama periode wajib diisi' : null,
                ),
                const SizedBox(height: AppSpacing.stackGap),

                Text('TAHUN MULAI', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: yearCtrl,
                  keyboardType: TextInputType.number,
                  style: AppTypography.bodyMd,
                  decoration: const InputDecoration(hintText: 'Contoh: 2027'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Tahun wajib diisi';
                    if (int.tryParse(v) == null) return 'Tahun harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                BrutalistButton(
                  label: 'BUAT PERIODE',
                  icon: Icons.check,
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    final year = int.parse(yearCtrl.text.trim());
                    context.read<PeriodeRepository>().addPeriode(PeriodeModel(
                      id: '',
                      nama: nameCtrl.text.trim(),
                      tanggalMulai: DateTime(year, 1, 1),
                      tanggalSelesai: DateTime(year + 1, 12, 31),
                      isActive: false,
                    ));
                    context.read<AuditLogRepository>().logAction(
                      aksi: 'Membuat periode baru: ${nameCtrl.text.trim()}',
                      tipe: 'Sistem',
                      entityType: 'periode',
                    );
                    Navigator.pop(dialogContext);
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
        onPressed: () => _showCreateDialog(context),
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
        child: Consumer<PeriodeRepository>(
          builder: (context, repo, _) {
            final periods = repo.periodes;
            if (periods.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada periode kepengurusan.',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              itemCount: periods.length,
              itemBuilder: (context, i) {
                final p = periods[i];
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
                                'Tahun Mulai: ${p.tanggalMulai.year}',
                                style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.isActive ? AppColors.success : AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                                ),
                                child: Text(
                                  p.isActive ? 'AKTIF' : 'TIDAK AKTIF',
                                  style: AppTypography.labelBold.copyWith(
                                    color: p.isActive ? Colors.white : AppColors.tertiary,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (!p.isActive)
                          BrutalistButton(
                            label: 'AKTIFKAN',
                            fullWidth: false,
                            onPressed: () => _setActive(context, p.id, p.nama),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
