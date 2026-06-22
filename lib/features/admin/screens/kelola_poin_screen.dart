import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/poin_model.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/poin_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';

class KelolaPoinScreen extends StatefulWidget {
  const KelolaPoinScreen({super.key});

  @override
  State<KelolaPoinScreen> createState() => _KelolaPoinScreenState();
}

class _KelolaPoinScreenState extends State<KelolaPoinScreen> {
  String _search = '';
  String _filterDiv = 'Semua';

  List<MemberModel> _getFiltered(List<MemberModel> members) {
    return members.where((m) {
      final matchSearch = _search.isEmpty ||
          m.nama.toLowerCase().contains(_search.toLowerCase()) ||
          m.nim.contains(_search);
      final matchDiv = _filterDiv == 'Semua' || (m.bidang == _filterDiv);
      return matchSearch && matchDiv;
    }).toList();
  }

  List<String> _buildDivisionFilter(List<MemberModel> members) {
    final divs = members
        .map((m) => m.bidang)
        .where((b) => b != null && b.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();
    return ['Semua', ...divs];
  }

  void _showAdjustPoinSheet(BuildContext context, MemberModel member, List<PoinEntryModel> allEntries) {
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    bool isAddition = true;
    final formKey = GlobalKey<FormState>();
    final history = allEntries.where((e) => e.memberId == member.id).take(10).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  topRight: Radius.circular(AppSpacing.radiusLg),
                ),
                border: Border(
                  top: BorderSide(color: AppColors.blackCharcoal, width: 2.5),
                  left: BorderSide(color: AppColors.blackCharcoal, width: 2.5),
                  right: BorderSide(color: AppColors.blackCharcoal, width: 2.5),
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(sheetContext).viewInsets.bottom),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kelola Poin Anggota',
                                style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                '${member.nama} (Poin saat ini: ${member.totalPoin})',
                                style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                          ),
                          child: Text(
                            '${member.totalPoin} PTS',
                            style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 16),

                    Text('AKSI MUTASI POIN', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isAddition = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isAddition ? AppColors.success : AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(AppSpacing.radius),
                                border: Border.all(color: AppColors.blackCharcoal, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  'TAMBAH (+)',
                                  style: AppTypography.labelBold.copyWith(
                                    color: isAddition ? Colors.white : AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => isAddition = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isAddition ? AppColors.errorContainer : AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(AppSpacing.radius),
                                border: Border.all(color: AppColors.blackCharcoal, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  'KURANG (-)',
                                  style: AppTypography.labelBold.copyWith(
                                    color: !isAddition ? AppColors.onErrorContainer : AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.stackGap),

                    Text('JUMLAH POIN', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      style: AppTypography.bodyMd,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan jumlah poin (contoh: 50)',
                        prefixIcon: Icon(Icons.stars, size: 20),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Jumlah poin wajib diisi';
                        final num = int.tryParse(v);
                        if (num == null || num <= 0) return 'Jumlah poin harus angka positif';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.stackGap),

                    Text('ALASAN / KETERANGAN', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: reasonCtrl,
                      style: AppTypography.bodyMd,
                      decoration: const InputDecoration(
                        hintText: 'Tulis alasan mutasi poin...',
                        prefixIcon: Icon(Icons.info_outline, size: 20),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Alasan wajib diisi' : null,
                    ),
                    const SizedBox(height: AppSpacing.stackGap),

                    Text('RIWAYAT MUTASI TERBARU', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 110),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                      ),
                      child: history.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text('Belum ada riwayat mutasi.', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 11)),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: history.length,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              itemBuilder: (context, idx) {
                                final h = history[idx];
                                final isAdd = h.poin >= 0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${h.label} (${h.tanggal.day}/${h.tanggal.month}/${h.tanggal.year})',
                                          style: AppTypography.bodyMd.copyWith(fontSize: 11, color: AppColors.tertiary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${isAdd ? '+' : ''}${h.poin} PTS',
                                        style: AppTypography.labelBold.copyWith(
                                          fontSize: 10,
                                          color: isAdd ? AppColors.success : AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 20),

                    BrutalistButton(
                      label: 'PROSES MUTASI POIN',
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final inputVal = int.parse(amountCtrl.text);
                        final actualVal = isAddition ? inputVal : -inputVal;

                        context.read<PoinRepository>().addPoinEntry(PoinEntryModel(
                          id: '',
                          memberId: member.id,
                          memberNama: member.nama,
                          label: reasonCtrl.text.trim(),
                          tipe: isAddition ? TipePoin.bonus : TipePoin.penalti,
                          poin: actualVal,
                          tanggal: DateTime.now(),
                          kegiatanId: null,
                        ));

                        context.read<MemberRepository>().updatePoin(member.id, actualVal);

                        context.read<AuditLogRepository>().logAction(
                          aksi: '${isAddition ? "Menambahkan +$inputVal" : "Mengurangi -$inputVal"} poin ke ${member.nama}: ${reasonCtrl.text.trim()}',
                          tipe: 'Poin',
                          entityId: member.id,
                          entityType: 'member',
                        );

                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Poin ${member.nama} berhasil diperbarui.',
                              style: AppTypography.bodyMd.copyWith(color: Colors.white),
                            ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberRepository>().members;
    final poinEntries = context.watch<PoinRepository>().poinEntries;
    final divisions = _buildDivisionFilter(members);
    final filteredList = _getFiltered(members);

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
                  'Kelola Poin Anggota',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.blackCharcoal, width: 2),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: AppTypography.bodyMd,
                      decoration: const InputDecoration(
                        hintText: 'Cari nama atau NIM...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: divisions.map((d) {
                        final active = _filterDiv == d;
                        return GestureDetector(
                          onTap: () => setState(() => _filterDiv = d),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                              border: Border.all(color: AppColors.blackCharcoal, width: 2),
                            ),
                            child: Text(d, style: AppTypography.labelBold.copyWith(
                              color: active ? AppColors.onPrimaryContainer : AppColors.onSurface,
                            )),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada anggota ditemukan.',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                      itemCount: filteredList.length,
                      itemBuilder: (context, i) {
                        final m = filteredList[i];
                        final initialName = m.nama.isNotEmpty
                            ? m.nama.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                            : 'M';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                          child: BrutalistCard(
                            onTap: () => _showAdjustPoinSheet(context, m, poinEntries),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                                    border: Border.all(color: AppColors.blackCharcoal, width: 1.8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initialName,
                                      style: AppTypography.labelBold.copyWith(
                                        fontSize: 14,
                                        color: AppColors.blackCharcoal,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.nama,
                                        style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${m.bidang ?? "-"} · NIM ${m.nim}',
                                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                                  ),
                                  child: Text(
                                    '${m.totalPoin} PTS',
                                    style: AppTypography.labelBold.copyWith(
                                      color: AppColors.blackCharcoal,
                                      fontSize: 11,
                                    ),
                                  ),
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
