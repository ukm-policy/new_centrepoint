import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../kegiatan_models.dart';

class DetailKegiatanScreen extends StatelessWidget {
  const DetailKegiatanScreen({super.key, required this.id});
  final String id;

  KegiatanItem get _item =>
      kKegiatanList.firstWhere((k) => k.id == id, orElse: () => kKegiatanList.first);

  bool get _canEdit => AppSession.isAdmin || AppSession.level >= 2;

  @override
  Widget build(BuildContext context) {
    final item = _item;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: _BackButton(),
            actions: [
              if (_canEdit)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur edit kegiatan segera hadir')),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        border: Border.all(color: AppColors.blackCharcoal, width: 2),
                        boxShadow: const [AppColors.hardShadowSm],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.edit_outlined, size: 16, color: AppColors.onSurface),
                        const SizedBox(width: 4),
                        Text('Edit', style: AppTypography.labelBold),
                      ]),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryContainer, AppColors.blackCharcoal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.event, size: 56, color: Colors.white54),
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

                  // ── Header info ────────────────────────────────────────────
                  _InfoCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        _StatusBadge(status: item.status),
                        const Spacer(),
                        Row(children: [
                          const Icon(Icons.people_outline, size: 14, color: AppColors.tertiary),
                          const SizedBox(width: 4),
                          Text('${item.pesertaTerdaftar}/${item.kuota}',
                            style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                        ]),
                      ]),
                      const SizedBox(height: 12),
                      Text(item.title,
                        style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      const MyDivider(color: AppColors.borderSlate),
                      const SizedBox(height: 16),
                      _InfoRow(icon: Icons.calendar_today_outlined,
                        text: '${item.tanggal}, ${item.waktu}'),
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.location_on_outlined, text: item.lokasi),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // ── Deskripsi ──────────────────────────────────────────────
                  _InfoCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Deskripsi', style: AppTypography.headlineSm),
                      const SizedBox(height: 12),
                      const MyDivider(color: AppColors.borderSlate, height: 12),
                      const SizedBox(height: 12),
                      Text(item.deskripsi,
                        style: AppTypography.bodyLg.copyWith(height: 1.7)),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // ── Panitia Inti ───────────────────────────────────────────
                  if (item.ketuaPelaksana != null ||
                      item.sekretarisPelaksana != null ||
                      item.bendaharaPelaksana != null) ...[
                    _InfoCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Icon(Icons.groups_outlined,
                            size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Panitia Inti', style: AppTypography.headlineSm),
                        ]),
                        const SizedBox(height: 12),
                        const MyDivider(color: AppColors.borderSlate, height: 12),
                        const SizedBox(height: 12),
                        if (item.ketuaPelaksana != null)
                          _PanitiaRow(
                            jabatan: 'Ketua Pelaksana',
                            panitia: item.ketuaPelaksana!,
                            isPrimary: true,
                          ),
                        if (item.sekretarisPelaksana != null) ...[
                          const SizedBox(height: 10),
                          _PanitiaRow(
                            jabatan: 'Sekretaris Pelaksana',
                            panitia: item.sekretarisPelaksana!,
                          ),
                        ],
                        if (item.bendaharaPelaksana != null) ...[
                          const SizedBox(height: 10),
                          _PanitiaRow(
                            jabatan: 'Bendahara Pelaksana',
                            panitia: item.bendaharaPelaksana!,
                          ),
                        ],
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                  ],

                  // ── Susunan Sie ────────────────────────────────────────────
                  if (item.sie.isNotEmpty) ...[
                    _InfoCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Icon(Icons.account_tree_outlined,
                            size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Susunan Sie', style: AppTypography.headlineSm),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(color: AppColors.borderSlate, width: 1.5),
                            ),
                            child: Text('${item.sie.length} Sie',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.tertiary, fontSize: 11)),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        const MyDivider(color: AppColors.borderSlate, height: 12),
                        const SizedBox(height: 8),
                        ...item.sie.asMap().entries.map((entry) {
                          final i = entry.key;
                          final sie = entry.value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (i > 0) ...[
                                const SizedBox(height: 16),
                                const MyDivider(color: AppColors.borderSlate, height: 8),
                                const SizedBox(height: 12),
                              ],
                              _SieSection(sie: sie),
                            ],
                          );
                        }),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                  ],

                  // ── Peserta preview ────────────────────────────────────────
                  _InfoCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text('Peserta Terdaftar', style: AppTypography.headlineSm),
                        const Spacer(),
                        Text('${item.pesertaTerdaftar} / ${item.kuota}',
                          style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                      ]),
                      const SizedBox(height: 12),
                      const MyDivider(color: AppColors.borderSlate, height: 12),
                      const SizedBox(height: 12),
                      Row(children: List.generate(
                        item.pesertaTerdaftar.clamp(0, 5),
                        (i) => Container(
                          margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.blackCharcoal, width: 2),
                          ),
                          child: const Icon(Icons.person, size: 18, color: AppColors.tertiary),
                        ),
                      )),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // ── Action button ──────────────────────────────────────────
                  if (item.status == 'Upcoming')
                    BrutalistButton(
                      label: 'DAFTAR SEKARANG',
                      icon: Icons.how_to_reg,
                      onPressed: () {},
                    )
                  else if (item.status == 'Berlangsung')
                    BrutalistButton(
                      label: 'ABSEN SEKARANG',
                      icon: Icons.fingerprint,
                      onPressed: () => context.push('/absensi'),
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Back Button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.canPop() ? context.pop() : context.go('/kegiatan'),
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

// ── Panitia Row ───────────────────────────────────────────────────────────────

class _PanitiaRow extends StatelessWidget {
  const _PanitiaRow({
    required this.jabatan,
    required this.panitia,
    this.isPrimary = false,
  });
  final String jabatan;
  final PanitiaItem panitia;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.primaryContainer.withAlpha(60) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: isPrimary ? AppColors.primaryContainer : AppColors.borderSlate,
          width: isPrimary ? 2 : 1.5,
        ),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blackCharcoal, width: 2),
          ),
          child: Icon(Icons.person_outline, size: 18,
            color: isPrimary ? AppColors.onPrimaryContainer : AppColors.tertiary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(jabatan, style: AppTypography.labelBold.copyWith(
              color: AppColors.tertiary, fontSize: 11, letterSpacing: 0.3)),
            const SizedBox(height: 2),
            Text(panitia.nama, style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.w700)),
          ]),
        ),
        Text(panitia.nim, style: AppTypography.labelBold.copyWith(
          color: AppColors.tertiary, fontSize: 11)),
      ]),
    );
  }
}

// ── Sie Section ───────────────────────────────────────────────────────────────

class _SieSection extends StatelessWidget {
  const _SieSection({required this.sie});
  final SieItem sie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sie header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.blackCharcoal,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(sie.namaSie, style: AppTypography.labelBold.copyWith(
            color: Colors.white, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 10),

        // Ketua Sie
        if (sie.ketua != null) ...[
          _MemberTile(
            nama: sie.ketua!.nama,
            nim: sie.ketua!.nim,
            role: 'Ketua ${sie.namaSie}',
            isKetua: true,
          ),
        ],

        // Anggota Sie
        ...sie.anggota.map((a) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: _MemberTile(
            nama: a.nama,
            nim: a.nim,
            role: 'Anggota',
          ),
        )),
      ],
    );
  }
}

// ── Member Tile ───────────────────────────────────────────────────────────────

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.nama,
    required this.nim,
    required this.role,
    this.isKetua = false,
  });
  final String nama, nim, role;
  final bool isKetua;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isKetua
            ? AppColors.secondaryContainer.withAlpha(80)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.borderSlate, width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: isKetua ? AppColors.secondaryContainer : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderSlate, width: 1.5),
          ),
          child: Icon(Icons.person_outline, size: 14,
            color: isKetua ? AppColors.onSecondaryContainer : AppColors.tertiary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(nama, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w700)),
            Text(role, style: AppTypography.labelBold.copyWith(
              color: AppColors.tertiary, fontSize: 10)),
          ]),
        ),
        Text(nim, style: AppTypography.labelBold.copyWith(
          color: AppColors.tertiary, fontSize: 11)),
      ]),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

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

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, textColor) = switch (status) {
      'Upcoming'    => (AppColors.secondaryContainer, AppColors.onSecondaryContainer),
      'Berlangsung' => (AppColors.primaryContainer, AppColors.onPrimaryContainer),
      _             => (AppColors.surfaceContainerHigh, AppColors.tertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Text(status, style: AppTypography.labelBold.copyWith(color: textColor)),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.tertiary),
      const SizedBox(width: 8),
      Expanded(child: Text(text,
        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface))),
    ]);
  }
}
