import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/member_repository.dart';

class ListMembersScreen extends StatefulWidget {
  const ListMembersScreen({super.key});

  @override
  State<ListMembersScreen> createState() => _ListMembersScreenState();
}

class _ListMembersScreenState extends State<ListMembersScreen> {
  String _search = '';
  String _filterDiv = 'Semua';

  final _divisions = ['Semua', 'Pemrograman', 'Jaringan', 'Multimedia', 'Pengembangan', 'Kaderisasi', 'Humas'];

  @override
  Widget build(BuildContext context) {
    final allMembers = context.watch<MemberRepository>().members.where((m) => m.isActive).toList();
    final filtered = allMembers.where((m) {
      final matchDiv = _filterDiv == 'Semua' || m.bidang == _filterDiv;
      final matchSearch = _search.isEmpty ||
          m.nama.toLowerCase().contains(_search.toLowerCase()) ||
          m.nim.contains(_search);
      return matchDiv && matchSearch;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FloatingAppBar(title: 'Daftar Anggota', showBack: true),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, AppSpacing.stackGap,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Search
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
              const SizedBox(height: AppSpacing.stackGap),

              // Division filter
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
                          boxShadow: [BoxShadow(
                            color: AppColors.blackCharcoal,
                            offset: active ? const Offset(2, 2) : const Offset(3, 3),
                            blurRadius: 0,
                          )],
                        ),
                        child: Text(d, style: AppTypography.labelBold.copyWith(
                          color: active ? AppColors.onPrimaryContainer : AppColors.onSurface,
                        )),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Member count
              Text(
                '${filtered.length} anggota',
                style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
              ),
              const SizedBox(height: 12),

              // Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.gutterGrid,
                  mainAxisSpacing: AppSpacing.gutterGrid,
                  childAspectRatio: 0.85,
                ),
                itemCount: filtered.length,
                itemBuilder: (_, i) => _MemberCard(member: filtered[i]),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});
  final MemberModel member;

  Color get _tierColor {
    return switch (member.tier) {
      'Gold' => const Color(0xFFFFF3CD),
      'Silver' => AppColors.surfaceContainerHigh,
      _ => const Color(0xFFFFE0CC),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      onTap: () => context.push('/anggota/${member.id}'),
      padding: const EdgeInsets.all(AppSpacing.innerPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blackCharcoal, width: 2),
              boxShadow: const [AppColors.hardShadowSm],
            ),
            child: const Icon(Icons.person, size: 32, color: AppColors.tertiary),
          ),
          const SizedBox(height: 10),
          Text(member.nama,
            style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(member.bidang ?? '-',
            style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
            textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _tierColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
            ),
            child: Text(member.tier, style: AppTypography.labelBold),
          ),
        ],
      ),
    );
  }
}
