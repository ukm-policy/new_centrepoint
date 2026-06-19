import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/my_divider.dart';

class DetailMemberScreen extends StatelessWidget {
  const DetailMemberScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: AppColors.bgGray,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.blackCharcoal, width: 2),
              boxShadow: const [AppColors.hardShadowSm],
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 20),
          ),
        ),
        title: Text('Profil Anggota', style: AppTypography.headlineSm),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginPage, 8, AppSpacing.marginPage, AppSpacing.stackGap,
        ),
        children: [
          // Profile card
          _InfoCard(child: Column(children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.blackCharcoal, width: 2.5),
                boxShadow: const [AppColors.hardShadow],
              ),
              child: const Icon(Icons.person, size: 52, color: AppColors.tertiary),
            ),
            const SizedBox(height: 12),
            Text('Ahmad Ridhwan',
              style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Senior Policy Analyst',
              style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _TierBadge(tier: 'Gold'),
              const SizedBox(width: 8),
              _DivisionBadge(division: 'Riset'),
            ]),
            const SizedBox(height: 16),
            const MyDivider(color: AppColors.borderSlate),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _StatColumn(value: '1250', label: 'Poin'),
              _VerticalDivider(),
              _StatColumn(value: '42', label: 'Kegiatan'),
              _VerticalDivider(),
              _StatColumn(value: '95%', label: 'Kehadiran'),
            ]),
          ])),
          const SizedBox(height: AppSpacing.stackGap),

          // Contact info
          _InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Informasi Kontak', style: AppTypography.headlineSm),
            const SizedBox(height: 12),
            const MyDivider(color: AppColors.borderSlate, height: 12),
            const SizedBox(height: 12),
            _ContactRow(icon: Icons.badge_outlined, label: 'NIM', value: '20210001'),
            const SizedBox(height: 10),
            _ContactRow(icon: Icons.email_outlined, label: 'Email', value: 'ahmad.ridhwan@email.com'),
            const SizedBox(height: 10),
            _ContactRow(icon: Icons.phone_outlined, label: 'No. HP', value: '+62 812 3456 7890'),
            const SizedBox(height: 10),
            _ContactRow(icon: Icons.school_outlined, label: 'Angkatan', value: '2021'),
          ])),
          const SizedBox(height: AppSpacing.stackGap),

          // Recent activity
          _InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Kegiatan Terakhir', style: AppTypography.headlineSm),
            const SizedBox(height: 12),
            const MyDivider(color: AppColors.borderSlate, height: 12),
            const SizedBox(height: 12),
            ...[
              ('Pelatihan Advokasi', '5 Okt 2023', true),
              ('Musyawarah Q3', '10 Okt 2023', true),
              ('Workshop Penulisan', '20 Agu 2023', false),
            ].map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: r.$3 ? AppColors.secondary : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(r.$1, style: AppTypography.bodyMd)),
                Text(r.$2, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
              ]),
            )),
          ])),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadow],
      ),
      child: child,
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});
  final String tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star, size: 14, color: AppColors.onSecondaryContainer),
        const SizedBox(width: 4),
        Text(tier, style: AppTypography.labelBold.copyWith(color: AppColors.onSecondaryContainer)),
      ]),
    );
  }
}

class _DivisionBadge extends StatelessWidget {
  const _DivisionBadge({required this.division});
  final String division;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
      ),
      child: Text(division, style: AppTypography.labelBold),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});
  final String value, label;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: AppTypography.headlineMd.copyWith(
        color: AppColors.primary, fontWeight: FontWeight.w800)),
      Text(label, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
    ]);
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 2, height: 36, color: AppColors.borderSlate);
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.tertiary),
      const SizedBox(width: 10),
      Text('$label: ', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
      Expanded(child: Text(value, style: AppTypography.bodyMd)),
    ]);
  }
}
