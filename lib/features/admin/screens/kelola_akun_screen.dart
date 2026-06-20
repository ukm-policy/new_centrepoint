import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/models/member_model.dart';

class KelolaAkunScreen extends StatefulWidget {
  const KelolaAkunScreen({super.key});

  @override
  State<KelolaAkunScreen> createState() => _KelolaAkunScreenState();
}

class _KelolaAkunScreenState extends State<KelolaAkunScreen> {
  String _search = '';
  String _filterStatus = 'Semua';
  String _filterDiv = 'Semua';

  final List<String> _statuses = ['Semua', 'Aktif', 'Pending', 'Suspended'];
  final List<String> _divisions = ['Semua', 'Pemrograman', 'Jaringan', 'Multimedia', 'Pengembangan', 'Kaderisasi', 'Humas'];

  void _showEditSheet(BuildContext context, MemberModel member) {
    String tempStatus = member.status;
    int tempLevel = member.level;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
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
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(modalContext).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ubah Pengaturan Akun',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${member.nama} · NIM ${member.nim}',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                  ),
                  const SizedBox(height: 12),
                  const MyDivider(color: AppColors.borderSlate),
                  const SizedBox(height: 16),

                  // Status Dropdown
                  Text('STATUS AKUN', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: tempStatus,
                    onChanged: (v) => setModalState(() => tempStatus = v ?? 'Aktif'),
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Aktif', child: Text('Aktif')),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending Verifikasi')),
                      DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // Level Dropdown
                  Text('LEVEL AKSES', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    value: tempLevel,
                    onChanged: (v) => setModalState(() => tempLevel = v ?? 2),
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Level 1 - Anggota Umum')),
                      DropdownMenuItem(value: 2, child: Text('Level 2 - Anggota Bidang')),
                      DropdownMenuItem(value: 3, child: Text('Level 3 - Kepala Bidang')),
                      DropdownMenuItem(value: 4, child: Text('Level 4 - Bendahara / Sekretaris')),
                      DropdownMenuItem(value: 5, child: Text('Level 5 - BPH / Ketua Umum')),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Save Button
                  BrutalistButton(
                    label: 'SIMPAN PERUBAHAN',
                    onPressed: () {
                      Provider.of<MemberRepository>(context, listen: false).updateStatusAndLevel(
                        member.id,
                        status: tempStatus,
                        level: tempLevel,
                      );
                      Navigator.pop(modalContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Akun ${member.nama} berhasil diperbarui.',
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
            );
          },
        );
      },
    );
  }

  Color _statusColor(String s) {
    return switch (s) {
      'Aktif' => AppColors.success,
      'Pending' => AppColors.secondaryContainer,
      _ => AppColors.errorContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final memberRepo = Provider.of<MemberRepository>(context);
    final members = memberRepo.members;

    final filtered = members.where((m) {
      final matchSearch = _search.isEmpty ||
          m.nama.toLowerCase().contains(_search.toLowerCase()) ||
          m.nim.contains(_search);
      final matchStatus = _filterStatus == 'Semua' || m.status == _filterStatus;
      final matchDiv = _filterDiv == 'Semua' || m.bidang == _filterDiv;
      return matchSearch && matchStatus && matchDiv;
    }).toList();

    final totalUsers = filtered.length;

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
                  'Kelola Pengguna ($totalUsers)',
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
            // Search Bar & Filters
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
                  
                  // Status Filter Scroll
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _statuses.map((s) {
                        final active = _filterStatus == s;
                        return GestureDetector(
                          onTap: () => setState(() => _filterStatus = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                              border: Border.all(color: AppColors.blackCharcoal, width: 2),
                            ),
                            child: Text(s, style: AppTypography.labelBold.copyWith(
                              color: active ? AppColors.onPrimaryContainer : AppColors.onSurface,
                            )),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Division Filter Scroll
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

            // Members list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada anggota ditemukan.',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final m = filtered[i];
                        final initialName = m.nama.isNotEmpty
                            ? m.nama.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                            : 'M';
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                          child: BrutalistCard(
                            onTap: () => _showEditSheet(context, m),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Avatar circle box
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                    border: Border.all(color: AppColors.blackCharcoal, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initialName,
                                      style: AppTypography.labelBold.copyWith(
                                        fontSize: 16,
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
                                      const SizedBox(height: 2),
                                      Text(
                                        '${m.jabatan ?? m.role.toUpperCase()} · NIM ${m.nim} (${m.angkatan})',
                                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          // Status badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _statusColor(m.status),
                                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                              border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                                            ),
                                            child: Text(
                                              m.status.toUpperCase(),
                                              style: AppTypography.labelBold.copyWith(
                                                color: m.status == 'Aktif' ? Colors.white : AppColors.onSurface,
                                                fontSize: 8,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // Level badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceContainerLowest,
                                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                              border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                                            ),
                                            child: Text(
                                              'LVL ${m.level}',
                                              style: AppTypography.labelBold.copyWith(
                                                fontSize: 8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.edit_outlined, size: 20, color: AppColors.tertiary),
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
