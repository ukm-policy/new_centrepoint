import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/models/absensi_model.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/absensi_repository.dart';

class DetailMemberScreen extends StatelessWidget {
  const DetailMemberScreen({super.key, required this.id});
  final String id;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  @override
  Widget build(BuildContext context) {
    final memberRepo = context.watch<MemberRepository>();
    final absensiRepo = context.watch<AbsensiRepository>();

    final member = memberRepo.members.firstWhere(
      (m) => m.id == id,
      orElse: () => memberRepo.members.first,
    );

    final memberAbsensi = absensiRepo.absensi.where((a) => a.memberId == id).toList();
    final recentActivities = memberAbsensi.map((a) {
      final isPresent = a.status == StatusAbsensi.hadir;
      final dateStr = a.waktuScan != null 
          ? '${a.waktuScan!.day} ${_months[a.waktuScan!.month - 1]} ${a.waktuScan!.year}' 
          : '-';
      return (a.kegiatanJudul, dateStr, isPresent);
    }).toList();

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
            Text(member.nama,
              style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(member.role,
              style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _TierBadge(tier: member.tier),
              const SizedBox(width: 8),
              _DivisionBadge(division: member.bidang ?? '-'),
            ]),
            const SizedBox(height: 16),
            const MyDivider(color: AppColors.borderSlate),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _StatColumn(value: '${member.totalPoin}', label: 'Poin'),
              _VerticalDivider(),
              _StatColumn(value: '${member.kegiatanCount}', label: 'Kegiatan'),
              _VerticalDivider(),
              _StatColumn(value: '${(member.kehadiranRate * 100).toInt()}%', label: 'Kehadiran'),
            ]),
          ])),
          const SizedBox(height: AppSpacing.stackGap),

          // Contact info
          _InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Informasi Kontak', style: AppTypography.headlineSm),
            const SizedBox(height: 12),
            const MyDivider(color: AppColors.borderSlate, height: 12),
            const SizedBox(height: 12),
            _ContactRow(icon: Icons.badge_outlined, label: 'NIM', value: member.nim),
            const SizedBox(height: 10),
            _ContactRow(icon: Icons.email_outlined, label: 'Email', value: member.email),
            const SizedBox(height: 10),
            _ContactRow(icon: Icons.phone_outlined, label: 'No. HP', value: member.noHp),
            const SizedBox(height: 10),
            _ContactRow(icon: Icons.school_outlined, label: 'Angkatan', value: member.angkatan),
          ])),
          const SizedBox(height: AppSpacing.stackGap),

          // Recent activity
          _InfoCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Kegiatan Terakhir', style: AppTypography.headlineSm),
            const SizedBox(height: 12),
            const MyDivider(color: AppColors.borderSlate, height: 12),
            const SizedBox(height: 12),
            if (recentActivities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Belum ada riwayat kegiatan', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
              )
            else
              ...recentActivities.map((r) => Padding(
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
