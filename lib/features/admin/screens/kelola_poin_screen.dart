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
import '../../../data/repositories/member_repository.dart';

class _LocalMutation {
  const _LocalMutation({
    required this.amount,
    required this.reason,
    required this.date,
  });
  final int amount;
  final String reason;
  final String date;
}

class KelolaPoinScreen extends StatefulWidget {
  const KelolaPoinScreen({super.key});

  @override
  State<KelolaPoinScreen> createState() => _KelolaPoinScreenState();
}

class _KelolaPoinScreenState extends State<KelolaPoinScreen> {
  late Map<String, int> _pointsMap;
  late Map<String, List<_LocalMutation>> _mutationHistory;
  bool _initialized = false;
  
  String _search = '';
  String _filterDiv = 'Semua';
  final List<String> _divisions = ['Semua', 'Pemrograman', 'Jaringan', 'Multimedia', 'Pengembangan', 'Kaderisasi', 'Humas'];

  void _initMaps(List<MemberModel> members) {
    if (_initialized) return;
    _pointsMap = {
      for (final m in members) m.id: m.totalPoin,
    };
    _mutationHistory = {
      for (final m in members)
        m.id: [
          const _LocalMutation(amount: 50, reason: 'Kehadiran Seminar Nasional', date: '18 Juni 2026'),
          const _LocalMutation(amount: -25, reason: 'Terlambat Rapat Evaluasi', date: '15 Juni 2026'),
          const _LocalMutation(amount: 100, reason: 'Menjadi Panitia Kegiatan', date: '10 Juni 2026'),
        ],
    };
    _initialized = true;
  }

  List<MemberModel> _getFiltered(List<MemberModel> members) {
    return members.where((m) {
      final matchSearch = _search.isEmpty ||
          m.nama.toLowerCase().contains(_search.toLowerCase()) ||
          m.nim.contains(_search);
      final matchDiv = _filterDiv == 'Semua' || (m.bidang == _filterDiv);
      return matchSearch && matchDiv;
    }).toList();
  }

  void _showAdjustPoinSheet(MemberModel member) {
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    bool isAddition = true; // toggle between + and -
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final history = _mutationHistory[member.id] ?? [];
            final currentPoin = _pointsMap[member.id] ?? 0;

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
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
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
                                '${member.nama} (Poin saat ini: $currentPoin)',
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
                            '$currentPoin PTS',
                            style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 16),

                    // Mutasi Segment (Tambah vs Kurang)
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

                    // Jumlah Poin
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

                    // Keterangan / Alasan
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

                    // Riwayat Mutasi User
                    Text('RIWAYAT MUTASI TERBARU', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 110),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: history.length,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemBuilder: (context, idx) {
                          final h = history[idx];
                          final isAdd = h.amount > 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${h.reason} (${h.date})',
                                    style: AppTypography.bodyMd.copyWith(fontSize: 11, color: AppColors.tertiary),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${isAdd ? '+' : ''}${h.amount} PTS',
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

                    // Submit
                    BrutalistButton(
                      label: 'PROSES MUTASI POIN',
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final inputVal = int.parse(amountCtrl.text);
                        final actualVal = isAddition ? inputVal : -inputVal;

                        context.read<MemberRepository>().updatePoin(member.id, actualVal);

                        setState(() {
                          _pointsMap[member.id] = currentPoin + actualVal;
                          _mutationHistory[member.id]!.insert(
                            0,
                            _LocalMutation(
                              amount: actualVal,
                              reason: reasonCtrl.text,
                              date: 'Hari ini',
                            ),
                          );
                        });

                        Navigator.pop(context);
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
    _initMaps(members);
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
            // Search Bar & Division Chips
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
                      children: _divisions.map((d) {
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

            // Members Point List
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
                        final pts = _pointsMap[m.id] ?? 0;
                        final initialName = m.nama.isNotEmpty
                            ? m.nama.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
                            : 'M';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                          child: BrutalistCard(
                            onTap: () => _showAdjustPoinSheet(m),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Avatar circle box
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

                                // Text details
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
                                
                                // Point score badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                                  ),
                                  child: Text(
                                    '$pts PTS',
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
