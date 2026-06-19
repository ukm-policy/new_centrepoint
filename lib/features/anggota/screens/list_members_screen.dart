import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';

const _kMembers = [
  _Member(id: '1', name: 'Ahmad Ridhwan', role: 'Senior Policy Analyst', division: 'Riset', tier: 'Gold'),
  _Member(id: '2', name: 'Siti Nurhaliza', role: 'Policy Writer', division: 'Publikasi', tier: 'Silver'),
  _Member(id: '3', name: 'Budi Santoso', role: 'Advocacy Lead', division: 'Advokasi', tier: 'Gold'),
  _Member(id: '4', name: 'Dewi Purnama', role: 'Research Associate', division: 'Riset', tier: 'Bronze'),
  _Member(id: '5', name: 'Faisal Hakim', role: 'Communications', division: 'Publikasi', tier: 'Silver'),
  _Member(id: '6', name: 'Rini Wulandari', role: 'Project Manager', division: 'Kegiatan', tier: 'Gold'),
];

class _Member {
  const _Member({
    required this.id, required this.name, required this.role,
    required this.division, required this.tier,
  });
  final String id, name, role, division, tier;
}

class ListMembersScreen extends StatefulWidget {
  const ListMembersScreen({super.key});

  @override
  State<ListMembersScreen> createState() => _ListMembersScreenState();
}

class _ListMembersScreenState extends State<ListMembersScreen> {
  String _search = '';
  String _filterDiv = 'Semua';

  final _divisions = ['Semua', 'Riset', 'Publikasi', 'Advokasi', 'Kegiatan'];

  List<_Member> get _filtered => _kMembers.where((m) {
        final matchDiv = _filterDiv == 'Semua' || m.division == _filterDiv;
        final matchSearch = _search.isEmpty ||
            m.name.toLowerCase().contains(_search.toLowerCase());
        return matchDiv && matchSearch;
      }).toList();

  @override
  Widget build(BuildContext context) {
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
                '${_filtered.length} anggota',
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
                itemCount: _filtered.length,
                itemBuilder: (_, i) => _MemberCard(member: _filtered[i]),
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
  final _Member member;

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
          Text(member.name,
            style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(member.division,
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
