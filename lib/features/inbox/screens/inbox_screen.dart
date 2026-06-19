import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../inbox_data.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _onlyUnread = false;
  final Set<String> _readIds = {};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
    for (final n in kInboxNotif) {
      if (n.isRead) _readIds.add(n.id);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  bool _isRead(String id) => _readIds.contains(id);

  void _markAllRead() =>
      setState(() => _readIds.addAll(kInboxNotif.map((n) => n.id)));

  int get _unreadCount => kInboxNotif.where((n) => !_isRead(n.id)).length;

  void _handleNotifTap(InboxNotifItem item) {
    setState(() => _readIds.add(item.id));
    if (item.route != null) context.push(item.route!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _InboxAppBar(
              onBack: () => context.pop(),
              unreadCount: _unreadCount,
              onMarkAll: _markAllRead,
            ),
            _BrutalistTabBar(controller: _tab),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _NotifTab(
                    items: kInboxNotif,
                    onlyUnread: _onlyUnread,
                    isRead: _isRead,
                    onToggleFilter: () =>
                        setState(() => _onlyUnread = !_onlyUnread),
                    onTap: _handleNotifTap,
                  ),
                  _PengumumanTab(items: kInboxPengumuman),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AppBar ────────────────────────────────────────────────────────────────────

class _InboxAppBar extends StatelessWidget {
  const _InboxAppBar({
    required this.onBack,
    required this.unreadCount,
    required this.onMarkAll,
  });
  final VoidCallback onBack, onMarkAll;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginPage,
        AppSpacing.marginPage,
        AppSpacing.marginPage,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: const [AppColors.hardShadow],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.onSurfaceVariant, size: 24),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'INBOX',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusNav),
                        border: Border.all(
                            color: AppColors.blackCharcoal, width: 1.5),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: AppTypography.labelBold.copyWith(
                          color: AppColors.onPrimaryContainer,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: unreadCount > 0 ? onMarkAll : null,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.done_all,
                  color: unreadCount > 0
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────

class _BrutalistTabBar extends StatelessWidget {
  const _BrutalistTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginPage, 12, AppSpacing.marginPage, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
        ),
        child: Row(
          children: [
            _TabPill(
              label: 'Notifikasi',
              active: controller.index == 0,
              onTap: () => controller.animateTo(0),
            ),
            _TabPill(
              label: 'Pengumuman',
              active: controller.index == 1,
              onTap: () => controller.animateTo(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: active
                ? Border.all(color: AppColors.blackCharcoal, width: 2)
                : null,
            boxShadow: active ? const [AppColors.hardShadowSm] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelBold.copyWith(
              color:
                  active ? AppColors.onSurface : AppColors.onSurfaceVariant,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Notifikasi Tab ────────────────────────────────────────────────────────────

class _NotifTab extends StatelessWidget {
  const _NotifTab({
    required this.items,
    required this.onlyUnread,
    required this.isRead,
    required this.onToggleFilter,
    required this.onTap,
  });
  final List<InboxNotifItem> items;
  final bool onlyUnread;
  final bool Function(String id) isRead;
  final VoidCallback onToggleFilter;
  final void Function(InboxNotifItem item) onTap;

  @override
  Widget build(BuildContext context) {
    final filtered =
        onlyUnread ? items.where((n) => !isRead(n.id)).toList() : items;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginPage,
        12,
        AppSpacing.marginPage,
        AppSpacing.marginPage + 16,
      ),
      children: [
        // Filter chip row
        Row(
          children: [
            GestureDetector(
              onTap: onToggleFilter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: onlyUnread
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerLowest,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusNav),
                  border:
                      Border.all(color: AppColors.blackCharcoal, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackCharcoal,
                      offset: onlyUnread
                          ? const Offset(2, 2)
                          : const Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'Belum Dibaca',
                  style: AppTypography.labelBold.copyWith(
                    color: onlyUnread
                        ? AppColors.onPrimaryContainer
                        : AppColors.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (filtered.isEmpty)
          const _EmptyState(
            icon: Icons.notifications_none,
            message: 'Tidak ada notifikasi belum dibaca',
          )
        else
          ...filtered.map(
            (n) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _NotifCard(
                item: n,
                read: isRead(n.id),
                onTap: () => onTap(n),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({
    required this.item,
    required this.read,
    required this.onTap,
  });
  final InboxNotifItem item;
  final bool read;
  final VoidCallback onTap;

  IconData get _icon => switch (item.type) {
        'poin' => Icons.workspace_premium,
        'kegiatan' => Icons.event_note,
        'absensi' => Icons.qr_code_scanner,
        'uang_khas' => Icons.account_balance_wallet,
        _ => Icons.info_outline,
      };

  Color get _iconColor => switch (item.type) {
        'poin' => AppColors.onSecondaryContainer,
        'kegiatan' => AppColors.primary,
        'absensi' => AppColors.secondary,
        'uang_khas' => const Color(0xFFB45309),
        _ => AppColors.tertiary,
      };

  Color get _iconBg => switch (item.type) {
        'poin' => AppColors.secondaryContainer,
        'kegiatan' => AppColors.errorContainer,
        'absensi' => const Color(0xFFD1FAE5),
        'uang_khas' => const Color(0xFFFEF3C7),
        _ => AppColors.surfaceContainerHigh,
      };

  @override
  Widget build(BuildContext context) {
    final hasNav = item.route != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: read ? AppColors.borderSlate : AppColors.blackCharcoal,
            width: read ? 1.5 : 2,
          ),
          boxShadow: read ? null : const [AppColors.hardShadowSm],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border:
                    Border.all(color: AppColors.blackCharcoal, width: 1.5),
              ),
              child: Icon(_icon, size: 20, color: _iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.bodyLg.copyWith(
                            fontWeight:
                                read ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (!read)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 5),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.tertiary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        item.time,
                        style: AppTypography.labelBold.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      if (hasNav) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm),
                            border: Border.all(
                                color: AppColors.blackCharcoal, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Buka',
                                style: AppTypography.labelBold.copyWith(
                                  fontSize: 11,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.arrow_forward,
                                  size: 11,
                                  color: AppColors.onSurface),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pengumuman Tab ────────────────────────────────────────────────────────────

class _PengumumanTab extends StatelessWidget {
  const _PengumumanTab({required this.items});
  final List<InboxPengumumanItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginPage,
        12,
        AppSpacing.marginPage,
        AppSpacing.marginPage + 16,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _PengumumanCard(item: items[i]),
    );
  }
}

class _PengumumanCard extends StatelessWidget {
  const _PengumumanCard({required this.item});
  final InboxPengumumanItem item;

  Color get _catColor => switch (item.category) {
        'PENTING' => AppColors.primaryContainer,
        'KEGIATAN' => AppColors.errorContainer,
        'KEUANGAN' => const Color(0xFFFEF3C7),
        'REKRUTMEN' => const Color(0xFFD1FAE5),
        'PRESTASI' => const Color(0xFFFFF3CD),
        _ => AppColors.surfaceContainerHigh,
      };

  Color get _catText => switch (item.category) {
        'PENTING' => AppColors.onPrimaryContainer,
        'KEGIATAN' => AppColors.primary,
        'KEUANGAN' => const Color(0xFFB45309),
        'REKRUTMEN' => AppColors.secondary,
        'PRESTASI' => AppColors.onSecondaryContainer,
        _ => AppColors.onSurface,
      };

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      onTap: () => context.push('/inbox/pengumuman/${item.id}'),
      padding: const EdgeInsets.all(AppSpacing.innerPadding + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _catColor,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                      color: AppColors.blackCharcoal, width: 1.5),
                ),
                child: Text(
                  item.category,
                  style: AppTypography.labelBold.copyWith(
                    color: _catText,
                    fontSize: 10,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (item.isNew) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blackCharcoal,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    'BARU',
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.surfaceContainerLowest,
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                item.date,
                style: AppTypography.labelBold.copyWith(
                  color: AppColors.tertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: AppTypography.headlineSm.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.excerpt,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.tertiary,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Spacer(),
              Text(
                'Baca Selengkapnya',
                style: AppTypography.labelBold
                    .copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward,
                  size: 14, color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blackCharcoal, width: 2),
              boxShadow: const [AppColors.hardShadowSm],
            ),
            child: Icon(icon, size: 36, color: AppColors.tertiary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.bodyLg.copyWith(color: AppColors.tertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
