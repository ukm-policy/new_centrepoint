import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../kegiatan_models.dart';
import '../rapat_models.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class ListKegiatanScreen extends StatefulWidget {
  const ListKegiatanScreen({super.key});

  @override
  State<ListKegiatanScreen> createState() => _ListKegiatanScreenState();
}

class _ListKegiatanScreenState extends State<ListKegiatanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _isAcaraTab => _tabController.index == 0;
  bool get _canCreate => AppSession.level > 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            FloatingAppBar(
              title: 'Kegiatan',
              trailing: GestureDetector(
                onTap: () => context.push('/kegiatan/riwayat'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.history_outlined,
                    color: AppColors.onSurfaceVariant, size: 24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
              child: _KegiatanTabBar(controller: _tabController),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _AcaraTab(),
                  _RapatTab(),
                ],
              ),
            ),
          ],
        ),

        // FAB – buat acara/rapat
        if (_canCreate)
          Positioned(
            right: AppSpacing.marginPage,
            bottom: 16,
            child: _BrutalistFAB(
              icon: _isAcaraTab ? Icons.event_outlined : Icons.meeting_room_outlined,
              label: _isAcaraTab ? 'Buat Acara' : 'Buat Rapat',
              onTap: () => _isAcaraTab
                  ? context.push('/kegiatan/buat')
                  : context.push('/kegiatan/rapat/buat'),
            ),
          ),
      ],
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────────

class _BrutalistFAB extends StatefulWidget {
  const _BrutalistFAB({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_BrutalistFAB> createState() => _BrutalistFABState();
}

class _BrutalistFABState extends State<_BrutalistFAB> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: _pressed
            ? Matrix4.translationValues(3, 3, 0)
            : Matrix4.identity(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackCharcoal,
              offset: _pressed ? const Offset(1, 1) : const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(widget.icon, color: AppColors.onPrimaryContainer, size: 20),
          const SizedBox(width: 8),
          Text(widget.label, style: AppTypography.labelBold.copyWith(
            color: AppColors.onPrimaryContainer)),
        ]),
      ),
    );
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────

class _KegiatanTabBar extends StatelessWidget {
  const _KegiatanTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Row(
        children: ['Acara', 'Rapat'].asMap().entries.map((entry) {
          final i = entry.key;
          final label = entry.value;
          final active = controller.index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  border: active
                      ? Border.all(color: AppColors.blackCharcoal, width: 1.5)
                      : null,
                  boxShadow: active ? const [AppColors.hardShadowSm] : null,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelBold.copyWith(
                    color: active
                        ? AppColors.onPrimaryContainer
                        : AppColors.tertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Tab 0: Acara ──────────────────────────────────────────────────────────────

class _AcaraTab extends StatefulWidget {
  const _AcaraTab();

  @override
  State<_AcaraTab> createState() => _AcaraTabState();
}

class _AcaraTabState extends State<_AcaraTab> {
  String _filter = 'Semua';

  List<KegiatanItem> get _filtered => kKegiatanList
      .where((k) => _filter == 'Semua' || k.status == _filter)
      .toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginPage, AppSpacing.stackGap,
        AppSpacing.marginPage, 80, // room for FAB
      ),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Semua', 'Upcoming', 'Berlangsung', 'Selesai'].map((f) {
              final active = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                    border: Border.all(color: AppColors.blackCharcoal, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackCharcoal,
                        offset: active ? const Offset(2, 2) : const Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(f, style: AppTypography.labelBold.copyWith(
                    color: active ? AppColors.onPrimaryContainer : AppColors.onSurface,
                  )),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        ..._filtered.map((k) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
          child: BrutalistCard(
            onTap: () => context.push('/kegiatan/${k.id}'),
            padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _StatusBadge(status: k.status),
                const Spacer(),
                Row(children: [
                  const Icon(Icons.people_outline, size: 14, color: AppColors.tertiary),
                  const SizedBox(width: 4),
                  Text('${k.pesertaTerdaftar}/${k.kuota}',
                    style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                ]),
              ]),
              const SizedBox(height: 10),
              Text(k.title, style: AppTypography.headlineSm),
              const SizedBox(height: 10),
              const MyDivider(color: AppColors.borderSlate, height: 12),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.tertiary),
                const SizedBox(width: 6),
                Text(k.tanggal,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.tertiary),
                const SizedBox(width: 6),
                Expanded(child: Text(k.lokasi,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                  overflow: TextOverflow.ellipsis)),
              ]),
              if (k.ketuaPelaksana != null) ...[
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.person_outline, size: 14, color: AppColors.tertiary),
                  const SizedBox(width: 6),
                  Expanded(child: Text('Ketua: ${k.ketuaPelaksana!.nama}',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    overflow: TextOverflow.ellipsis)),
                ]),
              ],
            ]),
          ),
        )),
      ],
    );
  }
}

// ── Tab 1: Rapat ──────────────────────────────────────────────────────────────

class _RapatTab extends StatefulWidget {
  const _RapatTab();

  @override
  State<_RapatTab> createState() => _RapatTabState();
}

class _RapatTabState extends State<_RapatTab> {
  String _category = 'Semua'; // 'Semua' | 'Acara' | 'Kepengurusan'

  List<RapatItem> get _visible => kRapatList
      .where(isRapatVisible)
      .where((r) {
        if (_category == 'Acara') return r.tipe.isAcaraRelated;
        if (_category == 'Kepengurusan') return !r.tipe.isAcaraRelated;
        return true;
      })
      .toList();

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginPage, AppSpacing.stackGap,
        AppSpacing.marginPage, 80,
      ),
      children: [
        // Category filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Semua', 'Acara', 'Kepengurusan'].map((c) {
              final active = _category == c;
              return GestureDetector(
                onTap: () => setState(() => _category = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.blackCharcoal
                        : AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                    border: Border.all(color: AppColors.blackCharcoal, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blackCharcoal,
                        offset: active ? const Offset(2, 2) : const Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(c, style: AppTypography.labelBold.copyWith(
                    color: active ? Colors.white : AppColors.onSurface,
                  )),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Info: berapa rapat visible
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: AppColors.borderSlate, width: 1.5),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 14, color: AppColors.tertiary),
            const SizedBox(width: 6),
            Text(
              '${visible.length} rapat yang relevan dengan peran Anda',
              style: AppTypography.labelBold.copyWith(
                color: AppColors.tertiary, fontSize: 11),
            ),
          ]),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(children: [
              const Icon(Icons.meeting_room_outlined, size: 48, color: AppColors.tertiary),
              const SizedBox(height: 12),
              Text('Tidak ada rapat tersedia',
                style: AppTypography.headlineSm.copyWith(color: AppColors.tertiary)),
              const SizedBox(height: 4),
              Text('Rapat hanya ditampilkan sesuai peran Anda',
                style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                textAlign: TextAlign.center),
            ]),
          ),

        ...visible.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
          child: BrutalistCard(
            onTap: () => context.push('/kegiatan/rapat/${r.id}'),
            padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _TipeBadge(tipe: r.tipe),
                const Spacer(),
                _RapatStatusBadge(status: r.status),
              ]),
              const SizedBox(height: 10),
              Text(r.judul, style: AppTypography.headlineSm),
              if (r.kegiatanId != null) ...[
                const SizedBox(height: 4),
                _AcaraLabel(kegiatanId: r.kegiatanId!, namaSie: r.namaSie),
              ],
              const SizedBox(height: 10),
              const MyDivider(color: AppColors.borderSlate, height: 12),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.tertiary),
                const SizedBox(width: 6),
                Text('${r.tanggal}  •  ${r.waktu}',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.tertiary),
                const SizedBox(width: 6),
                Expanded(child: Text(r.lokasi,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                  overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.people_outline, size: 14, color: AppColors.tertiary),
                const SizedBox(width: 6),
                Text('${r.peserta.length} peserta',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
              ]),
            ]),
          ),
        )),
      ],
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

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

class _TipeBadge extends StatelessWidget {
  const _TipeBadge({required this.tipe});
  final RapatTipe tipe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tipe.badgeColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(tipe.icon, size: 11, color: tipe.badgeTextColor),
        const SizedBox(width: 4),
        Text(tipe.labelShort, style: AppTypography.labelBold.copyWith(
          color: tipe.badgeTextColor, fontSize: 10)),
      ]),
    );
  }
}

class _RapatStatusBadge extends StatelessWidget {
  const _RapatStatusBadge({required this.status});
  final RapatStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Text(status.label, style: AppTypography.labelBold.copyWith(
        color: status.textColor, fontSize: 10)),
    );
  }
}

class _AcaraLabel extends StatelessWidget {
  const _AcaraLabel({required this.kegiatanId, this.namaSie});
  final String kegiatanId;
  final String? namaSie;

  @override
  Widget build(BuildContext context) {
    final kegiatan = kKegiatanList
        .where((k) => k.id == kegiatanId)
        .firstOrNull;
    if (kegiatan == null) return const SizedBox.shrink();
    final label = namaSie != null
        ? '${kegiatan.title} · $namaSie'
        : kegiatan.title;
    return Row(children: [
      const Icon(Icons.event_note_outlined, size: 12, color: AppColors.primary),
      const SizedBox(width: 4),
      Expanded(child: Text(label,
        style: AppTypography.labelBold.copyWith(
          color: AppColors.primary, fontSize: 11),
        overflow: TextOverflow.ellipsis)),
    ]);
  }
}
