import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/repositories/uang_khas_repository.dart';
import '../../../data/models/rekap_model.dart';

class RekapKeuanganScreen extends StatefulWidget {
  const RekapKeuanganScreen({super.key});

  @override
  State<RekapKeuanganScreen> createState() => _RekapKeuanganScreenState();
}

class _RekapKeuanganScreenState extends State<RekapKeuanganScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedSemester = 1; // 1=Jan-Jun, 2=Jul-Des, 0=Full Year
  bool _isLoading = false;
  bool _exporting = false;
  List<RekapBidangModel> _rekapData = [];

  final List<int> _years = [
    DateTime.now().year - 1,
    DateTime.now().year,
    DateTime.now().year + 1,
  ];

  static const _semesterOptions = [
    (label: 'Semester I (Jan - Jun)', value: 1),
    (label: 'Semester II (Jul - Des)', value: 2),
    (label: 'Full Year (Jan - Des)', value: 0),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRekap());
  }

  Future<void> _loadRekap() async {
    setState(() => _isLoading = true);
    try {
      final data = await context.read<UangKhasRepository>().getRekapKeuangan(
        _selectedYear,
        _selectedSemester,
      );
      if (mounted) setState(() => _rekapData = data);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _totalTarget => _rekapData.fold(0, (s, r) => s + r.target);
  int get _totalTerkumpul => _rekapData.fold(0, (s, r) => s + r.terkumpul);
  int get _totalSisa => _totalTarget - _totalTerkumpul;
  double get _totalPct => _totalTarget > 0 ? (_totalTerkumpul / _totalTarget).clamp(0.0, 1.0) : 0.0;

  String _fmt(int val) => val.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );

  String get _rangeLabel => _semesterOptions
      .firstWhere((s) => s.value == _selectedSemester)
      .label;

  Future<void> _export() async {
    if (_rekapData.isEmpty) return;
    setState(() => _exporting = true);
    try {
      final rows = <List<dynamic>>[
        ['Bidang', 'Jml Anggota', 'Target (Rp)', 'Terkumpul (Rp)', 'Sisa (Rp)', 'Persentase'],
        ..._rekapData.map((r) => [
          r.bidang,
          r.jumlahAnggota,
          r.target,
          r.terkumpul,
          r.sisa,
          '${(r.pct * 100).toStringAsFixed(1)}%',
        ]),
        ['TOTAL', '', _totalTarget, _totalTerkumpul, _totalSisa, '${(_totalPct * 100).toStringAsFixed(1)}%'],
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/rekap_keuangan_${_selectedYear}_sem$_selectedSemester.csv');
      await file.writeAsString(csv);

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Rekap Keuangan $_selectedYear - $_rangeLabel',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal export: $e', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.marginPage),
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Rekap Keuangan', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
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
              // Filter card
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
                          DropdownButtonFormField<int>(
                            initialValue: _selectedYear,
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _selectedYear = v);
                              _loadRekap();
                            },
                            style: AppTypography.bodyMd.copyWith(fontSize: 12, color: AppColors.onSurface),
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                            items: _years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(),
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
                          DropdownButtonFormField<int>(
                            initialValue: _selectedSemester,
                            onChanged: (v) {
                              if (v == null) return;
                              setState(() => _selectedSemester = v);
                              _loadRekap();
                            },
                            style: AppTypography.bodyMd.copyWith(fontSize: 12, color: AppColors.onSurface),
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                            items: _semesterOptions.map((s) => DropdownMenuItem(
                              value: s.value,
                              child: Text(s.label, overflow: TextOverflow.ellipsis),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: AppSpacing.stackGap),
              ] else ...[
                // Summary card
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

                // Detail table
                if (_rekapData.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Tidak ada data untuk periode ini.', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                    ),
                  )
                else
                  BrutalistCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                                            color: r.pct >= 1.0 ? AppColors.success : AppColors.primaryContainer,
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
                                        child: Text('Rp ${_fmt(r.target)}',
                                          style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text('Rp ${_fmt(r.terkumpul)}',
                                          style: AppTypography.bodyMd.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: r.pct >= 1.0 ? AppColors.success : AppColors.onSurface,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
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
              ],

              const SizedBox(height: 28),
              _exporting
                  ? const Center(child: CircularProgressIndicator())
                  : BrutalistButton(
                      label: 'EXPORT LAPORAN CSV',
                      icon: Icons.download_outlined,
                      onPressed: _rekapData.isEmpty ? null : _export,
                    ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
