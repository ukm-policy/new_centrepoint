import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';

class DetailKegiatanScreen extends StatelessWidget {
  const DetailKegiatanScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: _BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primaryContainer,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryContainer, AppColors.blackCharcoal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(Icons.event, size: 60, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          _Badge(label: 'UPCOMING', color: AppColors.secondaryContainer,
                            textColor: AppColors.onSecondaryContainer),
                          const Spacer(),
                          Row(children: [
                            const Icon(Icons.people_outline, size: 14, color: AppColors.tertiary),
                            const SizedBox(width: 4),
                            Text('45 Peserta',
                              style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                          ]),
                        ]),
                        const SizedBox(height: 12),
                        Text('Seminar Kebijakan Publik 2023',
                          style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        const MyDivider(color: AppColors.borderSlate),
                        const SizedBox(height: 16),
                        _InfoRow(icon: Icons.calendar_today_outlined, text: '28 Oktober 2023, 09.00 WIB'),
                        const SizedBox(height: 8),
                        _InfoRow(icon: Icons.location_on_outlined, text: 'Aula Utama Kampus, Gedung A'),
                        const SizedBox(height: 8),
                        _InfoRow(icon: Icons.person_outline, text: 'Panitia: Divisi Kegiatan'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // Deskripsi
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Deskripsi', style: AppTypography.headlineSm),
                        const SizedBox(height: 12),
                        const MyDivider(color: AppColors.borderSlate, height: 12),
                        const SizedBox(height: 12),
                        Text(
                          'Seminar ini membahas kebijakan publik terkini yang berdampak pada '
                          'masyarakat luas. Narasumber akan memaparkan analisis mendalam beserta '
                          'rekomendasi strategis untuk perbaikan kebijakan ke depan.\n\n'
                          'Peserta diharapkan membawa kartu anggota dan hadir 15 menit sebelum acara dimulai.',
                          style: AppTypography.bodyLg.copyWith(height: 1.7),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // Preview peserta
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('Peserta Terdaftar', style: AppTypography.headlineSm),
                          const Spacer(),
                          Text('45 / 60', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                        ]),
                        const SizedBox(height: 12),
                        const MyDivider(color: AppColors.borderSlate, height: 12),
                        const SizedBox(height: 12),
                        Row(children: List.generate(5, (i) => Container(
                          margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.blackCharcoal, width: 2),
                          ),
                          child: const Icon(Icons.person, size: 18, color: AppColors.tertiary),
                        ))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action button
                  BrutalistButton(
                    label: 'DAFTAR SEKARANG',
                    icon: Icons.how_to_reg,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.textColor});
  final String label;
  final Color color, textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Text(label, style: AppTypography.labelBold.copyWith(color: textColor)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.tertiary),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface))),
    ]);
  }
}
