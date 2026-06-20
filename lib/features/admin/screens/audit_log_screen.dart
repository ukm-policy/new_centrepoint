import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';

class _AuditLog {
  const _AuditLog({
    required this.adminName,
    required this.action,
    required this.time,
    required this.type,
  });
  final String adminName, action, time, type;
}

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _search = '';
  String _filterType = 'Semua';

  final List<String> _types = ['Semua', 'Verifikasi', 'Poin', 'Keuangan', 'Kegiatan', 'Sistem'];

  final List<_AuditLog> _logs = const [
    _AuditLog(adminName: 'Ahmad Rizky Pratama', action: 'Melakukan verifikasi anggota baru (Nabila Syakieb)', time: '10 menit yang lalu', type: 'Verifikasi'),
    _AuditLog(adminName: 'Ahmad Rizky Pratama', action: 'Mengubah status iuran kas bulanan (Farhan Maulana - Juli)', time: '1 jam yang lalu', type: 'Keuangan'),
    _AuditLog(adminName: 'Citra Amelia', action: 'Menambahkan +50 poin keaktifan (Sarah Azhari)', time: '2 jam yang lalu', type: 'Poin'),
    _AuditLog(adminName: 'Ahmad Rizky Pratama', action: 'Membuat QR Absensi Rapat Umum Q3', time: '1 hari yang lalu', type: 'Kegiatan'),
    _AuditLog(adminName: 'Sari Dewi', action: 'Mengedit detail berita seminar nasional', time: '2 hari yang lalu', type: 'Sistem'),
    _AuditLog(adminName: 'Siti Nurhaliza', action: 'Melakukan login admin', time: '3 hari yang lalu', type: 'Sistem'),
  ];

  List<_AuditLog> get _filtered {
    return _logs.where((l) {
      final matchSearch = _search.isEmpty ||
          l.adminName.toLowerCase().contains(_search.toLowerCase()) ||
          l.action.toLowerCase().contains(_search.toLowerCase());
      final matchType = _filterType == 'Semua' || l.type == _filterType;
      return matchSearch && matchType;
    }).toList();
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'Verifikasi' => Icons.verified_user_outlined,
      'Poin' => Icons.stars_outlined,
      'Keuangan' => Icons.payments_outlined,
      'Kegiatan' => Icons.event_available_outlined,
      _ => Icons.settings_outlined,
    };
  }

  Color _colorForType(String type) {
    return switch (type) {
      'Verifikasi' => AppColors.primaryContainer,
      'Poin' => AppColors.secondaryContainer,
      'Keuangan' => AppColors.errorContainer,
      'Kegiatan' => AppColors.success,
      _ => AppColors.surfaceContainerHigh,
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
                  'Audit Log Sistem',
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
            // Search Bar & Filter Chips
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
                        hintText: 'Cari berdasarkan nama admin / aksi...',
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
                      children: _types.map((t) {
                        final active = _filterType == t;
                        return GestureDetector(
                          onTap: () => setState(() => _filterType = t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                              border: Border.all(color: AppColors.blackCharcoal, width: 2),
                            ),
                            child: Text(t, style: AppTypography.labelBold.copyWith(
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

            // Timeline Logs
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada aktivitas ditemukan.',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final log = _filtered[i];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline stem indicator
                            Column(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: _colorForType(log.type),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.blackCharcoal, width: 2),
                                  ),
                                  child: Icon(_iconForType(log.type), size: 14, color: AppColors.blackCharcoal),
                                ),
                                if (i < _filtered.length - 1)
                                  Container(width: 2, height: 75, color: AppColors.borderSlate),
                              ],
                            ),
                            const SizedBox(width: 12),

                            // Detail Card
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.gutterGrid),
                                child: BrutalistCard(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(log.adminName, style: AppTypography.labelBold),
                                          Text(log.time, style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 10)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      const MyDivider(color: AppColors.borderSlate, height: 8),
                                      const SizedBox(height: 6),
                                      Text(log.action, style: AppTypography.bodyMd),
                                      const SizedBox(height: 4),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerLowest,
                                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                            border: Border.all(color: AppColors.borderSlate, width: 1),
                                          ),
                                          child: Text(
                                            log.type.toUpperCase(),
                                            style: AppTypography.labelBold.copyWith(fontSize: 8, color: AppColors.tertiary),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
