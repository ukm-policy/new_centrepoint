import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/models/berita_model.dart';
import '../../../data/repositories/berita_repository.dart';

class KelolaBeritaScreen extends StatefulWidget {
  const KelolaBeritaScreen({super.key});

  @override
  State<KelolaBeritaScreen> createState() => _KelolaBeritaScreenState();
}

class _KelolaBeritaScreenState extends State<KelolaBeritaScreen> {
  String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _handleDelete(BuildContext context, String id) {
    Provider.of<BeritaRepository>(context, listen: false).deleteBerita(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berita berhasil dihapus.', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _handleToggleStatus(BuildContext context, BeritaModel item) {
    Provider.of<BeritaRepository>(context, listen: false).updateBerita(
      item.copyWith(isDraft: !item.isDraft),
    );
  }

  void _showFormDialog(BuildContext context, {BeritaModel? item}) {
    final titleCtrl = TextEditingController(text: item?.judul);
    final contentCtrl = TextEditingController(text: item?.konten);
    String selectedCat = item?.kategori ?? 'Berita';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (modalContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.blackCharcoal, width: 2.5),
          ),
          backgroundColor: AppColors.surface,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item == null ? 'Tulis Berita Baru' : 'Edit Berita',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
              GestureDetector(
                onTap: () => Navigator.pop(modalContext),
                child: const Icon(Icons.close, color: AppColors.tertiary),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const MyDivider(color: AppColors.borderSlate, height: 16),
                  
                  // Category
                  Text('KATEGORI', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCat,
                    onChanged: (v) => selectedCat = v ?? 'Berita',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Berita', child: Text('Berita')),
                      DropdownMenuItem(value: 'Pengumuman', child: Text('Pengumuman')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // Title
                  Text('JUDUL BERITA', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: titleCtrl,
                    style: AppTypography.bodyMd,
                    decoration: const InputDecoration(hintText: 'Tulis judul berita...'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Judul wajib diisi' : null,
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // Content
                  Text('KONTEN BERITA', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: contentCtrl,
                    maxLines: 5,
                    style: AppTypography.bodyMd,
                    decoration: const InputDecoration(hintText: 'Tulis konten berita lengkap...'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Konten wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),

                  BrutalistButton(
                    label: item == null ? 'TERBITKAN SEKARANG' : 'SIMPAN PERUBAHAN',
                    icon: Icons.check,
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final beritaRepo = Provider.of<BeritaRepository>(context, listen: false);
                      if (item == null) {
                        final newBerita = BeritaModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          judul: titleCtrl.text,
                          kategori: selectedCat,
                          konten: contentCtrl.text,
                          penulisId: '1',
                          penulisNama: 'Ahmad Ridhwan',
                          tanggalPublish: DateTime.now(),
                          isDraft: false,
                        );
                        beritaRepo.addBerita(newBerita);
                      } else {
                        final updated = item.copyWith(
                          judul: titleCtrl.text,
                          kategori: selectedCat,
                          konten: contentCtrl.text,
                        );
                        beritaRepo.updateBerita(updated);
                      }
                      Navigator.pop(modalContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(item == null ? 'Berita berhasil diterbitkan!' : 'Perubahan berita disimpan.',
                              style: AppTypography.bodyMd.copyWith(color: Colors.white)),
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final beritaRepo = Provider.of<BeritaRepository>(context);
    final beritaList = beritaRepo.berita;

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
                  'Kelola Berita',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(context),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: const BorderSide(color: AppColors.blackCharcoal, width: 2),
        ),
        icon: const Icon(Icons.edit_note, size: 20),
        label: Text('Tulis Berita', style: AppTypography.labelBold.copyWith(fontSize: 12)),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          itemCount: beritaList.length,
          itemBuilder: (context, i) {
            final news = beritaList[i];
            final isTerbit = !news.isDraft;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
              child: BrutalistCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isTerbit ? AppColors.success : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                          ),
                          child: Text(
                            isTerbit ? 'TERBIT' : 'DRAF',
                            style: AppTypography.labelBold.copyWith(
                              color: isTerbit ? Colors.white : AppColors.tertiary,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: AppColors.borderSlate, width: 1),
                          ),
                          child: Text(
                            news.kategori.toUpperCase(),
                            style: AppTypography.labelBold.copyWith(fontSize: 9),
                          ),
                        ),
                        const Spacer(),
                        Text(_fmtDate(news.tanggalPublish), style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(news.judul, style: AppTypography.headlineSm.copyWith(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      news.konten,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 12),
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _handleToggleStatus(context, news),
                          icon: Icon(isTerbit ? Icons.drafts : Icons.publish, size: 16, color: AppColors.tertiary),
                          label: Text(isTerbit ? 'Tarik Draf' : 'Terbitkan', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                          onPressed: () => _showFormDialog(context, item: news),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          onPressed: () => _handleDelete(context, news.id),
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
    );
  }
}
