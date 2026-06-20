import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../kegiatan/kegiatan_models.dart';

class KelolaKegiatanScreen extends StatefulWidget {
  const KelolaKegiatanScreen({super.key});

  @override
  State<KelolaKegiatanScreen> createState() => _KelolaKegiatanScreenState();
}

class _KelolaKegiatanScreenState extends State<KelolaKegiatanScreen> {
  String _filterStatus = 'Semua';
  late List<KegiatanItem> _kegiatanList;

  @override
  void initState() {
    super.initState();
    _kegiatanList = List.from(kKegiatanList);
  }

  void _handleDelete(String id) {
    setState(() {
      _kegiatanList.removeWhere((k) => k.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kegiatan berhasil dihapus.', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _showStatusDialog(KegiatanItem item) {
    showDialog(
      context: context,
      builder: (context) {
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
                label: 'Upcoming',
                color: AppColors.surfaceContainerHigh,
                onTap: () => _updateStatus(item.id, 'Upcoming'),
              ),
              const SizedBox(height: 8),
              _StatusOption(
                label: 'Berlangsung',
                color: AppColors.secondaryContainer,
                onTap: () => _updateStatus(item.id, 'Berlangsung'),
              ),
              const SizedBox(height: 8),
              _StatusOption(
                label: 'Selesai',
                color: AppColors.success,
                textColor: Colors.white,
                onTap: () => _updateStatus(item.id, 'Selesai'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateStatus(String id, String newStatus) {
    setState(() {
      final idx = _kegiatanList.indexWhere((k) => k.id == id);
      if (idx != -1) {
        final k = _kegiatanList[idx];
        _kegiatanList[idx] = KegiatanItem(
          id: k.id,
          title: k.title,
          tanggal: k.tanggal,
          waktu: k.waktu,
          lokasi: k.lokasi,
          status: newStatus,
          kuota: k.kuota,
          pesertaTerdaftar: k.pesertaTerdaftar,
          deskripsi: k.deskripsi,
          ketuaPelaksana: k.ketuaPelaksana,
          sekretarisPelaksana: k.sekretarisPelaksana,
          bendaharaPelaksana: k.bendaharaPelaksana,
          sie: k.sie,
        );
      }
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status kegiatan berhasil diperbarui!', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  List<KegiatanItem> get _filtered => _kegiatanList.where((k) {
        if (_filterStatus == 'Semua') return true;
        return k.status == _filterStatus;
      }).toList();

  Color _statusColor(String status) {
    return switch (status) {
      'Upcoming' => AppColors.surfaceContainerHigh,
      'Berlangsung' => AppColors.secondaryContainer,
      _ => AppColors.success,
    };
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
                  'Kelola Kegiatan',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
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
                  children: ['Semua', 'Upcoming', 'Berlangsung', 'Selesai'].map((f) {
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
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada kegiatan ditemukan.',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final k = _filtered[i];
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
                                        k.title,
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
                                        k.status,
                                        style: AppTypography.labelBold.copyWith(
                                          color: isSelesai ? Colors.white : AppColors.onSurface,
                                          fontSize: 9,
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
                                      onPressed: () => _showStatusDialog(k),
                                      icon: const Icon(Icons.change_circle_outlined, size: 16, color: AppColors.primary),
                                      label: Text('Ubah Status', style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                      onPressed: () => _handleDelete(k.id),
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
