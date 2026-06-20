import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../berita/berita_data.dart';

class KelolaBeritaScreen extends StatefulWidget {
  const KelolaBeritaScreen({super.key});

  @override
  State<KelolaBeritaScreen> createState() => _KelolaBeritaScreenState();
}

class _KelolaBeritaScreenState extends State<KelolaBeritaScreen> {
  late List<_AdminBeritaItem> _beritaList;

  @override
  void initState() {
    super.initState();
    // Load from centralized berita
    _beritaList = kBeritaList.map((b) => _AdminBeritaItem(
          id: b.id,
          date: b.date,
          title: b.title,
          category: b.category,
          content: b.content,
          status: 'Terbit', // default
        )).toList();
  }

  void _handleDelete(String id) {
    setState(() {
      _beritaList.removeWhere((b) => b.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berita berhasil dihapus.', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _handleToggleStatus(String id) {
    setState(() {
      final idx = _beritaList.indexWhere((b) => b.id == id);
      if (idx != -1) {
        final currentStatus = _beritaList[idx].status;
        _beritaList[idx] = _beritaList[idx].copyWith(
          status: currentStatus == 'Terbit' ? 'Draf' : 'Terbit',
        );
      }
    });
  }

  void _showFormDialog({_AdminBeritaItem? item}) {
    final titleCtrl = TextEditingController(text: item?.title);
    final contentCtrl = TextEditingController(text: item?.content);
    String selectedCat = item?.category ?? 'Berita';
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
              Text(item == null ? 'Tulis Berita Baru' : 'Edit Berita',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
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
                      setState(() {
                        if (item == null) {
                          _beritaList.insert(0, _AdminBeritaItem(
                            id: '${_beritaList.length + 1}',
                            date: 'Hari ini',
                            title: titleCtrl.text,
                            category: selectedCat,
                            content: contentCtrl.text,
                            status: 'Terbit',
                          ));
                        } else {
                          final idx = _beritaList.indexWhere((b) => b.id == item.id);
                          if (idx != -1) {
                            _beritaList[idx] = item.copyWith(
                              title: titleCtrl.text,
                              category: selectedCat,
                              content: contentCtrl.text,
                            );
                          }
                        }
                      });
                      Navigator.pop(context);
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
        onPressed: () => _showFormDialog(),
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
          itemCount: _beritaList.length,
          itemBuilder: (context, i) {
            final news = _beritaList[i];
            final isTerbit = news.status == 'Terbit';

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
                            news.status.toUpperCase(),
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
                            news.category.toUpperCase(),
                            style: AppTypography.labelBold.copyWith(fontSize: 9),
                          ),
                        ),
                        const Spacer(),
                        Text(news.date, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(news.title, style: AppTypography.headlineSm.copyWith(fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      news.content,
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
                          onPressed: () => _handleToggleStatus(news.id),
                          icon: Icon(isTerbit ? Icons.drafts : Icons.publish, size: 16, color: AppColors.tertiary),
                          label: Text(isTerbit ? 'Tarik Draf' : 'Terbitkan', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                          onPressed: () => _showFormDialog(item: news),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          onPressed: () => _handleDelete(news.id),
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

class _AdminBeritaItem {
  const _AdminBeritaItem({
    required this.id,
    required this.date,
    required this.title,
    required this.category,
    required this.content,
    required this.status,
  });

  final String id, date, title, category, content, status;

  _AdminBeritaItem copyWith({
    String? id,
    String? date,
    String? title,
    String? category,
    String? content,
    String? status,
  }) {
    return _AdminBeritaItem(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      status: status ?? this.status,
    );
  }
}
