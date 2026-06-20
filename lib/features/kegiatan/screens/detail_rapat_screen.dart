import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/models/rapat_model.dart';
import '../../../data/repositories/kegiatan_repository.dart';
import '../../../data/repositories/rapat_repository.dart';

class DetailRapatScreen extends StatelessWidget {
  const DetailRapatScreen({super.key, required this.id});
  final String id;

  bool get _canEdit => AppSession.isAdmin || AppSession.level >= 3;

  String _fmtDate(DateTime d) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final rapatRepo = context.watch<RapatRepository>();
    final kegiatanRepo = context.watch<KegiatanRepository>();

    final rapat = rapatRepo.rapat.firstWhere((r) => r.id == id, orElse: () => rapatRepo.rapat.first);
    final kegiatan = rapat.kegiatanId == null
        ? null
        : kegiatanRepo.kegiatan.where((k) => k.id == rapat.kegiatanId).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: _BackButton(),
            title: Text('Detail Rapat', style: AppTypography.headlineSm),
            centerTitle: true,
            actions: [
              if (_canEdit)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur edit rapat segera hadir')),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        border: Border.all(color: AppColors.blackCharcoal, width: 2),
                        boxShadow: const [AppColors.hardShadowSm],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.edit_outlined, size: 14, color: AppColors.onSurface),
                        const SizedBox(width: 4),
                        Text('Edit', style: AppTypography.labelBold.copyWith(fontSize: 12)),
                      ]),
                    ),
                  ),
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Header Info ──────────────────────────────────────────
                  _InfoCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        _TipeBadge(tipe: rapat.tipe),
                        const Spacer(),
                        _StatusBadge(status: rapat.status),
                      ]),
                      const SizedBox(height: 12),
                      Text(rapat.judul, style: AppTypography.headlineMd.copyWith(
                        fontWeight: FontWeight.w800)),

                      // Konteks acara (jika ada)
                      if (kegiatan != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withAlpha(30),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: AppColors.primaryContainer, width: 1.5),
                          ),
                          child: Row(children: [
                            const Icon(Icons.event_note_outlined, size: 14,
                              color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Terkait Acara',
                                  style: AppTypography.labelBold.copyWith(
                                    color: AppColors.primary, fontSize: 10)),
                                Text(kegiatan.judul,
                                  style: AppTypography.bodyMd.copyWith(
                                    fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                                if (rapat.namaSie != null)
                                  Text('· ${rapat.namaSie}',
                                    style: AppTypography.labelBold.copyWith(
                                      color: AppColors.tertiary, fontSize: 11)),
                              ],
                            )),
                          ]),
                        ),
                      ],

                      // Konteks org
                      if (!rapat.tipe.isAcaraRelated) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: AppColors.borderSlate, width: 1.5),
                          ),
                          child: Row(children: [
                            Icon(rapat.tipe.icon, size: 14, color: AppColors.tertiary),
                            const SizedBox(width: 6),
                            Text(
                              rapat.namaBidang != null
                                  ? 'Bidang ${rapat.namaBidang}'
                                  : rapat.denganKetuaBidang
                                      ? 'Stakeholder + Ketua Bidang'
                                      : 'Stakeholder Inti',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.tertiary, fontSize: 11),
                            ),
                          ]),
                        ),
                      ],

                      const SizedBox(height: 16),
                      const MyDivider(color: AppColors.borderSlate),
                      const SizedBox(height: 16),
                      _InfoRow(icon: Icons.calendar_today_outlined,
                        text: '${_fmtDate(rapat.tanggal)}  •  ${rapat.waktu}'),
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.location_on_outlined, text: rapat.lokasi),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // ── Agenda ───────────────────────────────────────────────
                  if (rapat.agenda.isNotEmpty)
                    _InfoCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Icon(Icons.format_list_bulleted_outlined,
                            size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Agenda', style: AppTypography.headlineSm),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(color: AppColors.borderSlate, width: 1.5),
                            ),
                            child: Text('${rapat.agenda.length} poin',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.tertiary, fontSize: 11)),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        const MyDivider(color: AppColors.borderSlate, height: 12),
                        const SizedBox(height: 8),
                        ...rapat.agenda.asMap().entries.map((e) {
                          final i = e.key;
                          final item = e.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.blackCharcoal, width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text('${i + 1}',
                                      style: AppTypography.labelBold.copyWith(
                                        color: AppColors.onPrimaryContainer, fontSize: 11)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.judul, style: AppTypography.bodyLg.copyWith(
                                        fontWeight: FontWeight.w600)),
                                      if (item.keterangan != null) ...[
                                        const SizedBox(height: 2),
                                        Text(item.keterangan!, style: AppTypography.bodyMd.copyWith(
                                          color: AppColors.tertiary, height: 1.5)),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ]),
                    ),
                  if (rapat.agenda.isNotEmpty) const SizedBox(height: AppSpacing.stackGap),

                  // ── Peserta ───────────────────────────────────────────────
                  _InfoCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.people_outline, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Peserta', style: AppTypography.headlineSm),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: AppColors.borderSlate, width: 1.5),
                          ),
                          child: Text('${rapat.pesertaIds.length} orang',
                            style: AppTypography.labelBold.copyWith(
                              color: AppColors.tertiary, fontSize: 11)),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      const MyDivider(color: AppColors.borderSlate, height: 12),
                      const SizedBox(height: 8),
                      ...rapat.pesertaIds.asMap().entries.map((e) {
                        final isCurrentUser = e.value == AppSession.nama;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? AppColors.primaryContainer
                                    : AppColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCurrentUser
                                      ? AppColors.primaryContainer
                                      : AppColors.borderSlate,
                                  width: 2),
                              ),
                              child: Icon(Icons.person_outline, size: 16,
                                color: isCurrentUser
                                    ? AppColors.onPrimaryContainer
                                    : AppColors.tertiary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(e.value, style: AppTypography.bodyMd.copyWith(
                              fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w400,
                            ))),
                            if (isCurrentUser)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.radiusSm),
                                ),
                                child: Text('Anda',
                                  style: AppTypography.labelBold.copyWith(
                                    color: AppColors.onPrimaryContainer, fontSize: 9)),
                              ),
                          ]),
                        );
                      }),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.stackGap),

                  // ── Notulensi ─────────────────────────────────────────────
                  if (rapat.notulensi != null) ...[
                    _InfoCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Icon(Icons.article_outlined,
                            size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Notulensi', style: AppTypography.headlineSm),
                        ]),
                        const SizedBox(height: 12),
                        const MyDivider(color: AppColors.borderSlate, height: 12),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(AppSpacing.radius),
                            border: Border.all(color: AppColors.borderSlate, width: 1.5),
                          ),
                          child: Text(rapat.notulensi!,
                            style: AppTypography.bodyLg.copyWith(height: 1.6)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                  ],

                  // ── Action Button ─────────────────────────────────────────
                  if (rapat.status == RapatStatus.terjadwal)
                    BrutalistButton(
                      label: 'KONFIRMASI HADIR',
                      icon: Icons.how_to_reg,
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kehadiran dikonfirmasi')),
                      ),
                    )
                  else if (rapat.status == RapatStatus.berlangsung)
                    BrutalistButton(
                      label: 'ABSEN SEKARANG',
                      icon: Icons.fingerprint,
                      onPressed: () => context.push('/absensi'),
                    )
                  else if (rapat.status == RapatStatus.selesai &&
                      rapat.notulensi == null && _canEdit)
                    BrutalistButton(
                      label: 'TAMBAH NOTULENSI',
                      icon: Icons.edit_note_outlined,
                      onPressed: () {
                        final ctrl = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Tambah Notulensi'),
                            content: TextField(
                              controller: ctrl,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                hintText: 'Tulis notulensi rapat di sini...',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (ctrl.text.trim().isNotEmpty) {
                                    context.read<RapatRepository>().updateNotulensi(rapat.id, ctrl.text.trim());
                                  }
                                  Navigator.pop(ctx);
                                },
                                child: const Text('Simpan'),
                              ),
                            ],
                          ),
                        );
                      },
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

// ── Badges ────────────────────────────────────────────────────────────────────

class _TipeBadge extends StatelessWidget {
  const _TipeBadge({required this.tipe});
  final RapatTipe tipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tipe.badgeColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(tipe.icon, size: 12, color: tipe.badgeTextColor),
        const SizedBox(width: 5),
        Text(tipe.labelShort, style: AppTypography.labelBold.copyWith(
          color: tipe.badgeTextColor, fontSize: 11)),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final RapatStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Text(status.label, style: AppTypography.labelBold.copyWith(
        color: status.textColor, fontSize: 11)),
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
