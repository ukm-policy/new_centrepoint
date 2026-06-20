import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';

class _RekapRow {
  const _RekapRow({
    required this.bidang,
    required this.target,
    required this.terkumpul,
  });
  final String bidang;
  final int target;
  final int terkumpul;

  int get sisa => target - terkumpul;
  double get pct => target > 0 ? (terkumpul / target).clamp(0.0, 1.0) : 0.0;
}

class RekapKeuanganScreen extends StatefulWidget {
  const RekapKeuanganScreen({super.key});

  @override
  State<RekapKeuanganScreen> createState() => _RekapKeuanganScreenState();
}

class _RekapKeuanganScreenState extends State<RekapKeuanganScreen> {
  String _selectedYear = '2026';
  String _selectedRange = 'Semester I (Jan - Jun)';
  bool _exporting = false;

  final List<String> _years = ['2025', '2026', '2027'];
  final List<String> _ranges = [
    'Semester I (Jan - Jun)',
    'Semester II (Jul - Des)',
    'Full Year (Jan - Des)',
  ];

  final List<_RekapRow> _rekapData = const [
    _RekapRow(bidang: 'Kas Umum', target: 2000000, terkumpul: 1800000),
    _RekapRow(bidang: 'Pemrograman', target: 1000000, terkumpul: 850000),
    _RekapRow(bidang: 'Jaringan', target: 800000, terkumpul: 700000),
    _RekapRow(bidang: 'Multimedia', target: 750000, terkumpul: 750000),
    _RekapRow(bidang: 'Pengembangan', target: 900000, terkumpul: 600000),
    _RekapRow(bidang: 'Kaderisasi', target: 850000, terkumpul: 800000),
    _RekapRow(bidang: 'Humas', target: 1200000, terkumpul: 900000),
  ];

  int get _totalTarget => _rekapData.fold(0, (sum, r) => sum + r.target);
  int get _totalTerkumpul => _rekapData.fold(0, (sum, r) => sum + r.terkumpul);
  int get _totalSisa => _totalTarget - _totalTerkumpul;
  double get _totalPct => _totalTarget > 0 ? (_totalTerkumpul / _totalTarget).clamp(0.0, 1.0) : 0.0;

  String _fmt(int val) {
    return val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _exporting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Rekap Keuangan $_selectedYear - $_selectedRange berhasil diexport ke CSV & PDF!',
          style: AppTypography.bodyMd.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
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
                  'Rekap Keuangan',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Period Selectors
              BrutalistCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.surfaceContainerLowest,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TAHUN', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, fontSize: 9)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedYear,
                            onChanged: (v) => setState(() => _selectedYear = v ?? _selectedYear),
                            style: AppTypography.bodyMd.copyWith(fontSize: 12, color: AppColors.onSurface),
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                            items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RANGE PERIODE', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, fontSize: 9)),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRange,
                            onChanged: (v) => setState(() => _selectedRange = v ?? _selectedRange),
                            style: AppTypography.bodyMd.copyWith(fontSize: 12, color: AppColors.onSurface),
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                            items: _ranges.map((r) => DropdownMenuItem(value: r, child: Text(r, overflow: TextOverflow.ellipsis))).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Ledger Summary Card
              BrutalistCard(
                backgroundColor: AppColors.blackCharcoal,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Terkumpul', style: AppTypography.labelBold.copyWith(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 6),
                    Text(
                      'Rp ${_fmt(_totalTerkumpul)}',
                      style: AppTypography.displayLgMobile.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const MyDivider(color: Colors.white24, height: 12),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TARGET TOTAL', style: AppTypography.labelBold.copyWith(color: Colors.white54, fontSize: 9)),
                              Text('Rp ${_fmt(_totalTarget)}', style: AppTypography.bodyLg.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SISA TARGET', style: AppTypography.labelBold.copyWith(color: Colors.white54, fontSize: 9)),
                              Text('Rp ${_fmt(_totalSisa)}', style: AppTypography.bodyLg.copyWith(color: AppColors.errorContainer, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _totalPct,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm - 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${(_totalPct * 100).toInt()}%',
                          style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Detailed Table
              BrutalistCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      color: AppColors.surfaceContainerHigh,
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text('BIDANG', style: AppTypography.labelBold.copyWith(fontSize: 10))),
                          Expanded(flex: 2, child: Text('TARGET', style: AppTypography.labelBold.copyWith(fontSize: 10), textAlign: TextAlign.right)),
                          Expanded(flex: 2, child: Text('TERKUMPUL', style: AppTypography.labelBold.copyWith(fontSize: 10), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    const MyDivider(color: AppColors.blackCharcoal, height: 1),
                    
                    // Table Rows
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _rekapData.length,
                      itemBuilder: (context, idx) {
                        final r = _rekapData[idx];
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              color: AppColors.surfaceContainerLowest,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.bidang, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceContainerHigh,
                                                  borderRadius: BorderRadius.circular(3),
                                                ),
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: FractionallySizedBox(
                                                    widthFactor: r.pct,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: r.pct == 1.0 ? AppColors.success : AppColors.primaryContainer,
                                                        borderRadius: BorderRadius.circular(3),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text('${(r.pct * 100).toInt()}%', style: AppTypography.labelBold.copyWith(fontSize: 8, color: AppColors.tertiary)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('Rp ${_fmt(r.target)}', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary), textAlign: TextAlign.right),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text('Rp ${_fmt(r.terkumpul)}', style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold, color: r.pct == 1.0 ? AppColors.success : AppColors.onSurface), textAlign: TextAlign.right),
                                  ),
                                ],
                              ),
                            ),
                            if (idx != _rekapData.length - 1)
                              const MyDivider(color: AppColors.borderSlate, height: 1),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Export Button
              _exporting
                  ? const Center(child: CircularProgressIndicator())
                  : BrutalistButton(
                      label: 'EXPORT LAPORAN KEUANGAN',
                      icon: Icons.download_outlined,
                      onPressed: _export,
                    ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
