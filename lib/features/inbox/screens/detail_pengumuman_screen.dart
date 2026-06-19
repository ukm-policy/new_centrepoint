import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../inbox_data.dart';

class DetailPengumumanScreen extends StatelessWidget {
  const DetailPengumumanScreen({super.key, required this.id});
  final String id;

  InboxPengumumanItem get _item =>
      kInboxPengumuman.firstWhere((p) => p.id == id);

  Color get _catColor => switch (_item.category) {
        'PENTING' => AppColors.primaryContainer,
        'KEGIATAN' => AppColors.errorContainer,
        'KEUANGAN' => const Color(0xFFFEF3C7),
        'REKRUTMEN' => const Color(0xFFD1FAE5),
        'PRESTASI' => const Color(0xFFFFF3CD),
        _ => AppColors.surfaceContainerHigh,
      };

  Color get _catText => switch (_item.category) {
        'PENTING' => AppColors.onPrimaryContainer,
        'KEGIATAN' => AppColors.primary,
        'KEUANGAN' => const Color(0xFFB45309),
        'REKRUTMEN' => AppColors.secondary,
        'PRESTASI' => AppColors.onSecondaryContainer,
        _ => AppColors.onSurface,
      };

  IconData get _catIcon => switch (_item.category) {
        'PENTING' => Icons.warning_amber_rounded,
        'KEGIATAN' => Icons.event_note,
        'KEUANGAN' => Icons.account_balance_wallet,
        'REKRUTMEN' => Icons.group_add,
        'PRESTASI' => Icons.emoji_events,
        _ => Icons.campaign,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginPage,
                  AppSpacing.marginPage,
                  AppSpacing.marginPage,
                  0,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                    border:
                        Border.all(color: AppColors.blackCharcoal, width: 2),
                    boxShadow: const [AppColors.hardShadow],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.arrow_back,
                              color: AppColors.onSurfaceVariant, size: 24),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'PENGUMUMAN',
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      // Placeholder to balance the row
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),

            // ── Hero Banner ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginPage,
                  12,
                  AppSpacing.marginPage,
                  0,
                ),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.blackCharcoal,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                        color: AppColors.blackCharcoal, width: 2),
                    boxShadow: const [AppColors.hardShadow],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg - 2),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _catColor.withValues(alpha: 0.35),
                                AppColors.blackCharcoal,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Grid pattern
                        Opacity(
                          opacity: 0.06,
                          child: CustomPaint(
                            painter: _GridPainter(),
                          ),
                        ),
                        // Content
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _catColor.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _catColor.withValues(alpha: 0.6),
                                  width: 2,
                                ),
                              ),
                              child: Icon(_catIcon,
                                  size: 32, color: _catColor),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _catColor,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm),
                                    border: Border.all(
                                        color: AppColors.blackCharcoal,
                                        width: 1.5),
                                  ),
                                  child: Text(
                                    _item.category,
                                    style: AppTypography.labelBold.copyWith(
                                      color: _catText,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                if (_item.isNew) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm),
                                      border: Border.all(
                                          color: AppColors.blackCharcoal,
                                          width: 1.5),
                                    ),
                                    child: Text(
                                      'BARU',
                                      style:
                                          AppTypography.labelBold.copyWith(
                                        color: AppColors.onSurface,
                                        fontSize: 9,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Title & Meta ──────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginPage,
                16,
                AppSpacing.marginPage,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Date + reading time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm),
                          border: Border.all(
                              color: AppColors.blackCharcoal, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 12, color: AppColors.tertiary),
                            const SizedBox(width: 5),
                            Text(
                              _item.date,
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.tertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm),
                          border: Border.all(
                              color: AppColors.blackCharcoal, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time,
                                size: 12, color: AppColors.tertiary),
                            const SizedBox(width: 5),
                            Text(
                              '${_item.content.length * 2} mnt baca',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.tertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    _item.title,
                    style: AppTypography.headlineMd.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Divider
                  Container(
                    height: 3,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Content paragraphs
                  ..._item.content.map(
                    (para) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        para,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ),

                  // ── Action Card ───────────────────────────────────────
                  if (_item.actionLabel != null &&
                      _item.actionRoute != null) ...[
                    const SizedBox(height: 8),
                    BrutalistCard(
                      padding: const EdgeInsets.all(AppSpacing.innerPadding),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radius),
                              border: Border.all(
                                  color: AppColors.blackCharcoal, width: 1.5),
                            ),
                            child: const Icon(Icons.open_in_new,
                                size: 18,
                                color: AppColors.onPrimaryContainer),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tindak Lanjut',
                                  style: AppTypography.labelBold.copyWith(
                                    color: AppColors.tertiary,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _item.actionLabel!,
                                  style: AppTypography.bodyLg.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(_item.actionRoute!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.blackCharcoal,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radius),
                                boxShadow: const [AppColors.hardShadowSm],
                              ),
                              child: Text(
                                'Buka',
                                style: AppTypography.labelBold.copyWith(
                                  color: AppColors.surfaceContainerLowest,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.marginPage + 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple grid background painter for banner
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceContainerLowest
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}
