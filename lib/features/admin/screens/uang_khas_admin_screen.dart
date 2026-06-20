import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/member_repository.dart';

class UangKhasAdminScreen extends StatefulWidget {
  const UangKhasAdminScreen({super.key});

  @override
  State<UangKhasAdminScreen> createState() => _UangKhasAdminScreenState();
}

class _UangKhasAdminScreenState extends State<UangKhasAdminScreen> {
  String _search = '';
  String _filterDiv = 'Semua';
  final List<String> _divisions = ['Semua', 'Pemrograman', 'Jaringan', 'Multimedia', 'Pengembangan', 'Kaderisasi', 'Humas'];

  // Mock iuran: map each member to a 12-month boolean payment list (true = lunas)
  late Map<String, List<bool>> _paymentMap;
  bool _initialized = false;

  void _initPaymentMap(List<MemberModel> members) {
    if (_initialized) return;
    _paymentMap = {
      for (final m in members)
        m.id: List.generate(12, (index) => index < 6), // 6 months paid by default
    };
    _initialized = true;
  }

  void _toggleMonthPayment(String memberId, int monthIdx) {
    setState(() {
      final list = _paymentMap[memberId];
      if (list != null) {
        list[monthIdx] = !list[monthIdx];
      }
    });
  }

  int get _totalPaidMonths {
    int total = 0;
    if (!_initialized) return 0;
    for (final list in _paymentMap.values) {
      total += list.where((paid) => paid).length;
    }
    return total;
  }

  int get _totalUnpaidMonths {
    int total = 0;
    if (!_initialized) return 0;
    for (final list in _paymentMap.values) {
      total += list.where((paid) => !paid).length;
    }
    return total;
  }

  int get _totalFundsCollected => _totalPaidMonths * 20000; // Rp 20.000 per month iuran
  int get _totalPendingFunds => _totalUnpaidMonths * 20000;

  List<MemberModel> _getFiltered(List<MemberModel> members) {
    return members.where((m) {
      final matchDiv = _filterDiv == 'Semua' || m.bidang == _filterDiv;
      final matchSearch = _search.isEmpty ||
          m.nama.toLowerCase().contains(_search.toLowerCase()) ||
          m.nim.contains(_search);
      return matchDiv && matchSearch;
    }).toList();
  }

  final List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  void _showPaymentUpdateSheet(MemberModel member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final monthsList = _paymentMap[member.id]!;
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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(member.nama, style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
                  Text('${member.role} · NIM ${member.nim}', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                  const SizedBox(height: 12),
                  const MyDivider(color: AppColors.borderSlate),
                  const SizedBox(height: 16),
                  Text('STATUS PEMBAYARAN IURAN 2026', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, i) {
                      final isLunas = monthsList[i];
                      return GestureDetector(
                        onTap: () {
                          _toggleMonthPayment(member.id, i);
                          setModalState(() {});
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isLunas ? AppColors.success : AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(AppSpacing.radius),
                            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              _months[i],
                              style: AppTypography.labelBold.copyWith(
                                color: isLunas ? Colors.white : AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
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
    _initPaymentMap(members);
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
                  'Kas Semua Anggota',
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
            // Top Summary Card
            Padding(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              child: BrutalistCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.surfaceContainerLowest,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TERKUMPUL', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                          const SizedBox(height: 2),
                          Text('Rp ${_totalFundsCollected.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: AppTypography.headlineSm.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(width: 1.5, height: 40, color: AppColors.borderSlate),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BELUM BAYAR', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                          const SizedBox(height: 2),
                          Text('Rp ${_totalPendingFunds.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: AppTypography.headlineSm.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar & Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
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
                        hintText: 'Cari anggota...',
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
            const SizedBox(height: 16),

            // Members iuran grid list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                itemCount: filteredList.length,
                itemBuilder: (context, i) {
                  final member = filteredList[i];
                  final monthsList = _paymentMap[member.id]!;
                  final paidCount = monthsList.where((paid) => paid).length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                    child: BrutalistCard(
                      onTap: () => _showPaymentUpdateSheet(member),
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
                                  Text(member.nama, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                                  Text('${member.bidang ?? "-"} · NIM ${member.nim}', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: paidCount == 12 ? AppColors.success : AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                                ),
                                child: Text(
                                  '$paidCount/12 Lunas',
                                  style: AppTypography.labelBold.copyWith(
                                    color: paidCount == 12 ? Colors.white : AppColors.onSurface,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const MyDivider(color: AppColors.borderSlate),
                          const SizedBox(height: 10),
                          
                          // 12-month dot status grid representation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(12, (index) {
                              final isLunas = monthsList[index];
                              return Column(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: isLunas ? AppColors.success : AppColors.errorContainer,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.blackCharcoal, width: 1),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _months[index].substring(0, 1),
                                    style: AppTypography.labelBold.copyWith(fontSize: 8, color: AppColors.tertiary),
                                  ),
                                ],
                              );
                            }),
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
