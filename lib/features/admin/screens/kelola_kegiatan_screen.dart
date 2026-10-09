import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/models/kegiatan_model.dart';
import '../../../data/repositories/kegiatan_repository.dart';
import '../../../shared/utils/feedback.dart';
import '../../../shared/widgets/floating_app_bar.dart';

class KelolaKegiatanScreen extends StatefulWidget {
  const KelolaKegiatanScreen({super.key});

  @override
  State<KelolaKegiatanScreen> createState() => _KelolaKegiatanScreenState();
}

class _KelolaKegiatanScreenState extends State<KelolaKegiatanScreen> {
  String _filterStatus = 'Semua';

  void _handleDelete(BuildContext context, String id) {
    final repo = Provider.of<KegiatanRepository>(context, listen: false);
    runWithFeedback(
      context,
      () => repo.deleteKegiatan(id),
      success: 'Kegiatan berhasil dihapus.',
      errorPrefix: 'Gagal menghapus kegiatan',
    );
  }

  void _showStatusDialog(BuildContext context, KegiatanModel item) {
    showDialog(
      context: context,
      builder: (modalContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.blackCharcoal, width: 2.5),
          ),
          backgroundColor: AppColors.surface,
          title: Text('Ubah Status Kegiatan', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MyDivider(color: AppColors.borderSlate, height: 16),
              _StatusOption(
                label: 'Akan Datang',
                color: AppColors.surfaceContainerHigh,
                onTap: () => _updateStatus(context, item, 'Akan Datang'),
              ),
              const SizedBox(height: 8),
              _StatusOption(
                label: 'Berlangsung',
                color: AppColors.secondaryContainer,
                onTap: () => _updateStatus(context, item, 'Berlangsung'),
              ),
              const SizedBox(height: 8),
              _StatusOption(
                label: 'Selesai',
                color: AppColors.success,
                textColor: Colors.white,
                onTap: () => _updateStatus(context, item, 'Selesai'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateStatus(BuildContext context, KegiatanModel item, String newStatus) {
    final repo = Provider.of<KegiatanRepository>(context, listen: false);
    Navigator.pop(context);
    runWithFeedback(
      context,
      () => repo.updateKegiatan(item.copyWith(status: newStatus)),
      success: 'Status kegiatan berhasil diperbarui!',
      errorPrefix: 'Gagal memperbarui status',
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'Akan Datang' || 'Upcoming' => AppColors.surfaceContainerHigh,
      'Berlangsung' => AppColors.secondaryContainer,
      _ => AppColors.success,
    };
  }

  @override
  Widget build(BuildContext context) {
    final kegiatanRepo = Provider.of<KegiatanRepository>(context);
    final kegiatanList = kegiatanRepo.kegiatan;

    final filtered = kegiatanList.where((k) {
      if (_filterStatus == 'Semua') return true;
      // 'Upcoming' = nilai lama untuk 'Akan Datang'.
      final status = k.status == 'Upcoming' ? 'Akan Datang' : k.status;
      return status == _filterStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: PageAppBar(title: 'Kelola Kegiatan'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/kegiatan/buat'),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: const BorderSide(color: AppColors.blackCharcoal, width: 2),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: Text('Tambah Acara', style: AppTypography.labelBold.copyWith(fontSize: 12)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips
            Padding(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Akan Datang', 'Berlangsung', 'Selesai'].map((f) {
                    final active = _filterStatus == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filterStatus = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            ),

            // Kegiatan list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada kegiatan ditemukan.',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final k = filtered[i];
                        final isSelesai = k.status == 'Selesai';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                          child: BrutalistCard(
                            onTap: () => context.push('/kegiatan/${k.id}'),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        k.judul,
                                        style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _statusColor(k.status),
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                        border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                                      ),
                                      child: Text(
                                        k.status == 'Upcoming' ? 'Akan Datang' : k.status,
                                        style: AppTypography.labelBold.copyWith(
                                          color: isSelesai ? Colors.white : AppColors.onSurface,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('Lokasi: ${k.lokasi} · ${k.pesertaTerdaftar}/${k.kuota} Peserta', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                                const SizedBox(height: 12),
                                const MyDivider(color: AppColors.borderSlate),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _showStatusDialog(context, k),
                                      icon: const Icon(Icons.change_circle_outlined, size: 16, color: AppColors.primary),
                                      label: Text('Ubah Status', style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                      onPressed: () => _handleDelete(context, k.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelBold.copyWith(
              color: textColor ?? AppColors.onSurface,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
