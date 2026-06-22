import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../../data/models/audit_log_model.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _search = '';
  String _filterType = 'Semua';

  final List<String> _types = ['Semua', 'Verifikasi', 'Poin', 'Keuangan', 'Kegiatan', 'Sistem', 'OR'];

  List<AuditLogModel> _filtered(List<AuditLogModel> logs) {
    return logs.where((l) {
      final matchSearch = _search.isEmpty ||
          l.adminNama.toLowerCase().contains(_search.toLowerCase()) ||
          l.aksi.toLowerCase().contains(_search.toLowerCase());
      final matchType = _filterType == 'Semua' || l.tipe == _filterType;
      return matchSearch && matchType;
    }).toList();
  }

  IconData _iconForType(String type) => switch (type) {
    'Verifikasi' => Icons.verified_user_outlined,
    'Poin' => Icons.stars_outlined,
    'Keuangan' => Icons.payments_outlined,
    'Kegiatan' => Icons.event_available_outlined,
    'OR' => Icons.people_outline,
    _ => Icons.settings_outlined,
  };

  Color _colorForType(String type) => switch (type) {
    'Verifikasi' => AppColors.primaryContainer,
    'Poin' => AppColors.secondaryContainer,
    'Keuangan' => AppColors.errorContainer,
    'Kegiatan' => AppColors.success,
    'OR' => AppColors.tertiaryContainer,
    _ => AppColors.surfaceContainerHigh,
  };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}d lalu';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuditLogRepository>(
      builder: (context, repo, _) {
        final filtered = _filtered(repo.logs);

        return Scaffold(
          backgroundColor: AppColors.bgGray,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage, vertical: 8),
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
                    Text('Audit Log Sistem', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
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

                Expanded(
                  child: repo.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? Center(
                              child: Text(
                                'Tidak ada aktivitas ditemukan.',
                                style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final log = filtered[i];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: _colorForType(log.tipe),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: AppColors.blackCharcoal, width: 2),
                                          ),
                                          child: Icon(_iconForType(log.tipe), size: 14, color: AppColors.blackCharcoal),
                                        ),
                                        if (i < filtered.length - 1)
                                          Container(width: 2, height: 75, color: AppColors.borderSlate),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
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
                                                  Text(log.adminNama, style: AppTypography.labelBold),
                                                  Text(_timeAgo(log.createdAt), style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 10)),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              const MyDivider(color: AppColors.borderSlate, height: 8),
                                              const SizedBox(height: 6),
                                              Text(log.aksi, style: AppTypography.bodyMd),
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
                                                    log.tipe.toUpperCase(),
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
      },
    );
  }
}
