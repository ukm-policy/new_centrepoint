import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../anggota/anggota_data.dart';

class _LocalAssignment {
  _LocalAssignment({
    required this.id,
    required this.name,
    required this.nim,
    required this.role,
    required this.division,
  });
  final String id, name, nim;
  String role;
  String division;
}

class AssignJabatanScreen extends StatefulWidget {
  const AssignJabatanScreen({super.key});

  @override
  State<AssignJabatanScreen> createState() => _AssignJabatanScreenState();
}

class _AssignJabatanScreenState extends State<AssignJabatanScreen> {
  late List<_LocalAssignment> _assignments;
  String _selectedPeriod = 'Periode 2026 / 2027';

  final List<String> _periods = [
    'Periode 2025 / 2026',
    'Periode 2026 / 2027',
    'Periode 2027 / 2028',
  ];

  final List<String> _roles = [
    'Ketua Umum',
    'Sekretaris',
    'Bendahara',
    'Kepala Bidang',
    'Staff Ahli',
    'Anggota Bidang',
    'Anggota Umum',
  ];

  final List<String> _divisions = [
    'Umum',
    'Riset',
    'Publikasi',
    'Advokasi',
    'Kegiatan',
  ];

  @override
  void initState() {
    super.initState();
    _assignments = kMemberList.map((m) {
      // Map specialized roles to generic ones for dropdown choices
      String genericRole = 'Anggota Bidang';
      if (m.role.contains('Lead') || m.role.contains('Manager')) {
        genericRole = 'Kepala Bidang';
      } else if (m.role.contains('Senior')) {
        genericRole = 'Staff Ahli';
      }
      return _LocalAssignment(
        id: m.id,
        name: m.name,
        nim: m.nim,
        role: genericRole,
        division: m.division,
      );
    }).toList();
  }

  void _saveAssignments() {
    // Simulate saving
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Assignment Jabatan & Bidang $_selectedPeriod berhasil disimpan!',
          style: AppTypography.bodyMd.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
    context.pop();
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
                  'Assign Jabatan',
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
            // Period Selector
            Padding(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              child: BrutalistCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.surfaceContainerLowest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PILIH PERIODE KEPENGURUSAN',
                      style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, fontSize: 10, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPeriod,
                      onChanged: (v) {
                        setState(() {
                          _selectedPeriod = v ?? _selectedPeriod;
                        });
                      },
                      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        prefixIcon: Icon(Icons.date_range_outlined, size: 18),
                      ),
                      items: _periods.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Members Table / Card list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                itemCount: _assignments.length,
                itemBuilder: (context, i) {
                  final assign = _assignments[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                    child: BrutalistCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(assign.name, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                                  Text('NIM ${assign.nim}', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 12)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                                ),
                                child: Text(
                                  'AKTIF',
                                  style: AppTypography.labelBold.copyWith(fontSize: 8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const MyDivider(color: AppColors.borderSlate),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Jabatan dropdown
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('JABATAN', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, fontSize: 9)),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      initialValue: assign.role,
                                      onChanged: (v) {
                                        setState(() {
                                          assign.role = v ?? assign.role;
                                        });
                                      },
                                      style: AppTypography.bodyMd.copyWith(fontSize: 12, color: AppColors.onSurface),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      ),
                                      items: _roles.map((r) => DropdownMenuItem(
                                        value: r,
                                        child: Text(r, style: const TextStyle(fontSize: 12)),
                                      )).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Bidang dropdown
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('BIDANG / DIVISI', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, fontSize: 9)),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      initialValue: assign.division,
                                      onChanged: (v) {
                                        setState(() {
                                          assign.division = v ?? assign.division;
                                        });
                                      },
                                      style: AppTypography.bodyMd.copyWith(fontSize: 12, color: AppColors.onSurface),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                      ),
                                      items: _divisions.map((d) => DropdownMenuItem(
                                        value: d,
                                        child: Text(d, style: const TextStyle(fontSize: 12)),
                                      )).toList(),
                                    ),
                                  ],
                                ),
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

            // Bottom Save button container
            Padding(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              child: BrutalistButton(
                label: 'SIMPAN ASSIGNMENT PERIODE',
                icon: Icons.save_outlined,
                onPressed: _saveAssignments,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
