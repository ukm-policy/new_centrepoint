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
import '../../../data/models/uang_khas_model.dart';
import '../../../data/repositories/uang_khas_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UangKhasAdminScreen extends StatefulWidget {
  const UangKhasAdminScreen({super.key});

  @override
  State<UangKhasAdminScreen> createState() => _UangKhasAdminScreenState();
}

class _UangKhasAdminScreenState extends State<UangKhasAdminScreen> {
  String _search = '';
  String _filterDiv = 'Semua';
  final List<String> _divisions = ['Semua', 'Pemrograman', 'Jaringan', 'Multimedia', 'Pengembangan', 'Kaderisasi', 'Humas'];

  final List<String> _months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  final List<String> _monthsShort = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  Future<void> _adminVerify(String id, String memberNama) async {
    context.read<UangKhasRepository>().verifyPayment(id, memberNama);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pembayaran $memberNama berhasil diverifikasi!'), backgroundColor: AppColors.success),
    );
  }

  Future<void> _adminReject(String id, String memberNama) async {
    context.read<UangKhasRepository>().rejectPayment(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pembayaran $memberNama ditolak.'), backgroundColor: AppColors.error),
    );
  }

  Future<void> _adminMarkLunas(String memberId, String bulan) async {
    try {
      final adminUid = Supabase.instance.client.auth.currentUser?.id;
      await Supabase.instance.client.from('uang_khas_bulan').upsert({
        'member_id': memberId,
        'bulan': bulan,
        'tahun': 2026,
        'nominal': 20000,
        'status': 'lunas',
        'is_verified': true,
        'verified_by': adminUid,
      }, onConflict: 'member_id, bulan, tahun');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _adminMarkBelumBayar(String memberId, String bulan) async {
    try {
      await Supabase.instance.client.from('uang_khas_bulan').delete().match({
        'member_id': memberId,
        'bulan': bulan,
        'tahun': 2026,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showPendingOptions(UangKhasBulanModel record, String memberNama) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Verifikasi Pembayaran', style: AppTypography.headlineSm),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Member: $memberNama', style: AppTypography.bodyMd),
              Text('Bulan: ${record.bulan} 2026', style: AppTypography.bodyMd),
              const SizedBox(height: 12),
              if (record.buktiUrl != null) ...[
                Text('Bukti Transfer:', style: AppTypography.labelBold),
                const SizedBox(height: 6),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radius - 1.5),
                    child: Image.network(
                      record.buktiUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => const Center(child: Text('Gagal memuat gambar')),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _adminReject(record.id, memberNama);
              },
              child: Text('TOLAK', style: AppTypography.labelBold.copyWith(color: AppColors.error)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _adminVerify(record.id, memberNama);
              },
              child: const Text('SETUJUI'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentUpdateSheet(MemberModel member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final khasRepo = context.watch<UangKhasRepository>();
            final currentKhas = khasRepo.khasBulan.where((k) => k.memberId == member.id && k.tahun == 2026).toList();

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
                      final monthName = _months[i];
                      final record = currentKhas.where((k) => k.bulan == monthName).firstOrNull;
                      
                      final isLunas = record?.status == StatusBayar.lunas;
                      final isPending = record?.status == StatusBayar.pending;

                      Color bg = AppColors.surfaceContainerLowest;
                      Color fg = AppColors.onSurface;
                      if (isLunas) {
                        bg = AppColors.success;
                        fg = Colors.white;
                      } else if (isPending) {
                        bg = AppColors.secondaryContainer;
                        fg = AppColors.onSecondaryContainer;
                      }

                      return GestureDetector(
                        onTap: () {
                          if (isPending && record != null) {
                            _showPendingOptions(record, member.nama);
                          } else if (isLunas) {
                            _adminMarkBelumBayar(member.id, monthName);
                          } else {
                            _adminMarkLunas(member.id, monthName);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(AppSpacing.radius),
                            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              _monthsShort[i],
                              style: AppTypography.labelBold.copyWith(
                                color: fg,
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

  List<MemberModel> _getFiltered(List<MemberModel> members) {
    return members.where((m) {
      final matchDiv = _filterDiv == 'Semua' || m.bidang == _filterDiv;
      final matchSearch = _search.isEmpty ||
          m.nama.toLowerCase().contains(_search.toLowerCase()) ||
          m.nim.contains(_search);
      return matchDiv && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final khasRepo = context.watch<UangKhasRepository>();
    final members = context.watch<MemberRepository>().members.where((m) => m.isActive).toList();
    
    final totalFundsCollected = khasRepo.khasBulan
        .where((k) => k.status == StatusBayar.lunas && k.tahun == 2026)
        .fold(0, (s, k) => s + k.nominal);
        
    final totalPendingFunds = khasRepo.khasBulan
        .where((k) => k.status == StatusBayar.pending && k.tahun == 2026)
        .fold(0, (s, k) => s + k.nominal);

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
                          Text('Rp ${totalFundsCollected.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
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
                          Text('PENDING VERIF', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                          const SizedBox(height: 2),
                          Text('Rp ${totalPendingFunds.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: AppTypography.headlineSm.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
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
                  final currentKhas = khasRepo.khasBulan.where((k) => k.memberId == member.id && k.tahun == 2026).toList();
                  final paidCount = currentKhas.where((k) => k.status == StatusBayar.lunas).length;

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
                              final record = currentKhas.where((k) => k.bulan == _months[index]).firstOrNull;
                              
                              final isLunas = record?.status == StatusBayar.lunas;
                              final isPending = record?.status == StatusBayar.pending;

                              Color dotColor = AppColors.errorContainer; // default unpaid
                              if (isLunas) {
                                dotColor = AppColors.success;
                              } else if (isPending) {
                                dotColor = AppColors.secondary;
                              }

                              return Column(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: dotColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.blackCharcoal, width: 1),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _monthsShort[index].substring(0, 1),
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
