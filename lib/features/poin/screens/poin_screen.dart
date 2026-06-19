import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────

const _kRiwayat = [
  _PoinEntry(
    label: 'Hadir — Seminar Kebijakan Publik',
    tanggal: '20 Jun 2025',
    poin: 50,
    tipe: _EntryTipe.hadir,
  ),
  _PoinEntry(
    label: 'Hadir — Rapat Koordinasi Divisi',
    tanggal: '19 Jun 2025',
    poin: 30,
    tipe: _EntryTipe.hadir,
  ),
  _PoinEntry(
    label: 'Panitia — Workshop Analisis Kebijakan',
    tanggal: '15 Jun 2025',
    poin: 100,
    tipe: _EntryTipe.panitia,
  ),
  _PoinEntry(
    label: 'Tidak Hadir — Diskusi Mingguan',
    tanggal: '12 Jun 2025',
    poin: -20,
    tipe: _EntryTipe.absen,
  ),
  _PoinEntry(
    label: 'Bonus — Kontribusi Materi Pelatihan',
    tanggal: '10 Jun 2025',
    poin: 75,
    tipe: _EntryTipe.bonus,
  ),
  _PoinEntry(
    label: 'Hadir — Rapat Pleno UKM',
    tanggal: '5 Jun 2025',
    poin: 40,
    tipe: _EntryTipe.hadir,
  ),
  _PoinEntry(
    label: 'Hadir — Seminar Nasional Kebijakan',
    tanggal: '1 Jun 2025',
    poin: 60,
    tipe: _EntryTipe.hadir,
  ),
  _PoinEntry(
    label: 'Tidak Hadir — Rapat Divisi Riset',
    tanggal: '28 Mei 2025',
    poin: -20,
    tipe: _EntryTipe.absen,
  ),
  _PoinEntry(
    label: 'Panitia — Pelantikan Anggota Baru',
    tanggal: '20 Mei 2025',
    poin: 80,
    tipe: _EntryTipe.panitia,
  ),
  _PoinEntry(
    label: 'Hadir — Workshop Penulisan Kebijakan',
    tanggal: '15 Mei 2025',
    poin: 50,
    tipe: _EntryTipe.hadir,
  ),
];

const _kLeaderboard = [
  _LeaderEntry(rank: 1, nama: 'Budi Santoso', divisi: 'Riset & Kebijakan', poin: 1580, tier: 'Gold'),
  _LeaderEntry(rank: 2, nama: 'Siti Rahayu', divisi: 'Komunikasi', poin: 1420, tier: 'Gold'),
  _LeaderEntry(rank: 3, nama: 'Ahmad Ridhwan', divisi: 'Analisis Kebijakan', poin: 1250, tier: 'Gold'),
  _LeaderEntry(rank: 4, nama: 'Dewi Lestari', divisi: 'Riset & Kebijakan', poin: 1100, tier: 'Silver'),
  _LeaderEntry(rank: 5, nama: 'Rizky Pratama', divisi: 'Komunikasi', poin: 980, tier: 'Silver'),
  _LeaderEntry(rank: 6, nama: 'Nurul Fadilah', divisi: 'Keuangan', poin: 870, tier: 'Silver'),
  _LeaderEntry(rank: 7, nama: 'Hendra Wijaya', divisi: 'Analisis Kebijakan', poin: 760, tier: 'Bronze'),
  _LeaderEntry(rank: 8, nama: 'Maya Putri', divisi: 'Riset & Kebijakan', poin: 650, tier: 'Bronze'),
  _LeaderEntry(rank: 9, nama: 'Fajar Ramadan', divisi: 'Komunikasi', poin: 540, tier: 'Bronze'),
  _LeaderEntry(rank: 10, nama: 'Indah Permata', divisi: 'Keuangan', poin: 420, tier: 'Bronze'),
];

enum _EntryTipe { hadir, absen, panitia, bonus }

class _PoinEntry {
  const _PoinEntry({
    required this.label,
    required this.tanggal,
    required this.poin,
    required this.tipe,
  });
  final String label, tanggal;
  final int poin;
  final _EntryTipe tipe;
}

class _LeaderEntry {
  const _LeaderEntry({
    required this.rank,
    required this.nama,
    required this.divisi,
    required this.poin,
    required this.tier,
  });
  final int rank, poin;
  final String nama, divisi, tier;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class PoinScreen extends StatefulWidget {
  const PoinScreen({super.key});

  @override
  State<PoinScreen> createState() => _PoinScreenState();
}

class _PoinScreenState extends State<PoinScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FloatingAppBar(title: 'Poin Keaktifan', showBack: true),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, AppSpacing.stackGap,
          ),
          children: [
            // ── Kartu Poin User ──────────────────────────────────────────
            _UserPoinCard(),
            const SizedBox(height: AppSpacing.stackGap),

            // ── Tab Bar ───────────────────────────────────────────────────
            _BrutalistTabBar(controller: _tab),
            const SizedBox(height: AppSpacing.stackGap),

            // ── Tab Content ───────────────────────────────────────────────
            _tab.index == 0
                ? _RiwayatTab()
                : _LeaderboardTab(),
          ],
        ),
      ),
    ]);
  }
}

// ── User Poin Card ────────────────────────────────────────────────────────────

class _UserPoinCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blackCharcoal,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadow],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: const Icon(Icons.person, size: 26, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ahmad Ridhwan',
              style: AppTypography.headlineSm.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            Text('Senior Policy Analyst',
              style: AppTypography.labelBold.copyWith(color: Colors.white54)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star, size: 12, color: AppColors.onSecondaryContainer),
              const SizedBox(width: 4),
              Text('Gold', style: AppTypography.labelBold.copyWith(color: AppColors.onSecondaryContainer)),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        const MyDivider(color: Colors.white12, height: 1),
        const SizedBox(height: 20),

        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Poin', style: AppTypography.labelBold.copyWith(color: Colors.white54)),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('1.250', style: AppTypography.displayLgMobile.copyWith(color: Colors.white)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('pts', style: AppTypography.bodyLg.copyWith(color: Colors.white54)),
              ),
            ]),
          ])),
          Container(width: 1, height: 56, color: Colors.white12),
          const SizedBox(width: 20),
          Expanded(child: Column(children: [
            _StatChip(label: 'Ranking', value: '#3', icon: Icons.emoji_events),
            const SizedBox(height: 8),
            _StatChip(label: 'Bulan Ini', value: '+445', icon: Icons.trending_up),
          ])),
        ]),

        const SizedBox(height: 16),
        // Progress bar ke tier berikutnya
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Menuju Platinum', style: AppTypography.labelBold.copyWith(color: Colors.white54)),
            const Spacer(),
            Text('1250 / 2000 pts', style: AppTypography.labelBold.copyWith(color: Colors.white38)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(children: [
              Container(height: 8, color: Colors.white12),
              FractionallySizedBox(
                widthFactor: 1250 / 2000,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 14, color: AppColors.primaryContainer),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: AppTypography.bodyLg.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          Text(label, style: AppTypography.labelBold.copyWith(color: Colors.white38, fontSize: 10)),
        ]),
      ]),
    );
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────

class _BrutalistTabBar extends StatelessWidget {
  const _BrutalistTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Row(children: [
        _TabPill(label: 'Riwayat Poin', icon: Icons.history, index: 0, controller: controller),
        _TabPill(label: 'Leaderboard', icon: Icons.leaderboard, index: 1, controller: controller),
      ]),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.icon,
    required this.index,
    required this.controller,
  });
  final String label;
  final IconData icon;
  final int index;
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final active = controller.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(
              color: active ? AppColors.blackCharcoal : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: active ? const [AppColors.hardShadowSm] : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16,
              color: active ? AppColors.onPrimaryContainer : AppColors.tertiary),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.labelBold.copyWith(
              color: active ? AppColors.onPrimaryContainer : AppColors.tertiary,
            )),
          ]),
        ),
      ),
    );
  }
}

// ── Tab Riwayat ───────────────────────────────────────────────────────────────

class _RiwayatTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Hitung summary
    final total = _kRiwayat.fold(0, (s, e) => s + e.poin);
    final masuk = _kRiwayat.where((e) => e.poin > 0).fold(0, (s, e) => s + e.poin);
    final keluar = _kRiwayat.where((e) => e.poin < 0).fold(0, (s, e) => s + e.poin.abs());

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Summary row
      Row(children: [
        _SummaryBox(label: 'Didapat', value: '+$masuk', color: AppColors.secondaryContainer,
          textColor: AppColors.onSecondaryContainer, icon: Icons.arrow_upward),
        const SizedBox(width: AppSpacing.gutterGrid),
        _SummaryBox(label: 'Dikurangi', value: '-$keluar', color: AppColors.errorContainer,
          textColor: AppColors.error, icon: Icons.arrow_downward),
        const SizedBox(width: AppSpacing.gutterGrid),
        _SummaryBox(label: 'Periode Ini', value: '${total > 0 ? "+" : ""}$total',
          color: AppColors.surfaceContainerLowest, textColor: AppColors.onSurface,
          icon: Icons.summarize_outlined),
      ]),
      const SizedBox(height: AppSpacing.stackGap),

      Text('${_kRiwayat.length} aktivitas',
        style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
      const SizedBox(height: 10),

      // List
      ..._kRiwayat.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.gutterGrid),
        child: _RiwayatCard(entry: e),
      )),
    ]);
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label, required this.value,
    required this.color, required this.textColor, required this.icon,
  });
  final String label, value;
  final Color color, textColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: const [AppColors.hardShadowSm],
        ),
        child: Column(children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.headlineSm.copyWith(color: textColor)),
          Text(label, style: AppTypography.labelBold.copyWith(color: textColor.withValues(alpha: 0.7), fontSize: 10)),
        ]),
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  const _RiwayatCard({required this.entry});
  final _PoinEntry entry;

  IconData get _icon => switch (entry.tipe) {
    _EntryTipe.hadir   => Icons.event_available,
    _EntryTipe.absen   => Icons.event_busy,
    _EntryTipe.panitia => Icons.groups,
    _EntryTipe.bonus   => Icons.card_giftcard,
  };

  Color get _iconBg => switch (entry.tipe) {
    _EntryTipe.hadir   => AppColors.secondaryContainer,
    _EntryTipe.absen   => AppColors.errorContainer,
    _EntryTipe.panitia => AppColors.primaryContainer,
    _EntryTipe.bonus   => const Color(0xFFFFF3CD),
  };

  Color get _iconColor => switch (entry.tipe) {
    _EntryTipe.hadir   => AppColors.onSecondaryContainer,
    _EntryTipe.absen   => AppColors.error,
    _EntryTipe.panitia => AppColors.onPrimaryContainer,
    _EntryTipe.bonus   => const Color(0xFF856404),
  };

  @override
  Widget build(BuildContext context) {
    final isPositive = entry.poin > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _iconBg,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
          ),
          child: Icon(_icon, size: 20, color: _iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.label,
            style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(entry.tanggal,
            style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
        ])),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isPositive ? AppColors.secondaryContainer : AppColors.errorContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
          ),
          child: Text(
            '${isPositive ? "+" : ""}${entry.poin}',
            style: AppTypography.labelBold.copyWith(
              color: isPositive ? AppColors.onSecondaryContainer : AppColors.error,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Tab Leaderboard ───────────────────────────────────────────────────────────

class _LeaderboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top3 = _kLeaderboard.take(3).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Podium top 3
      _Podium(top3: top3),
      const SizedBox(height: AppSpacing.stackGap),

      // Posisi user highlight
      _MyRankBanner(),
      const SizedBox(height: AppSpacing.stackGap),

      Text('Semua Peringkat', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
      const SizedBox(height: 10),

      ..._kLeaderboard.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.gutterGrid),
        child: _LeaderCard(entry: e, isMe: e.rank == 3),
      )),
    ]);
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top3});
  final List<_LeaderEntry> top3;

  @override
  Widget build(BuildContext context) {
    // Urutan podium: 2nd | 1st | 3rd
    final order = [top3[1], top3[0], top3[2]];
    final heights = [80.0, 110.0, 60.0];
    final ranks = [2, 1, 3];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.blackCharcoal,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadow],
      ),
      child: Column(children: [
        Text('TOP LEADERBOARD',
          style: AppTypography.labelBold.copyWith(color: Colors.white54, letterSpacing: 2)),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (i) => Expanded(
            child: _PodiumSlot(
              entry: order[i],
              height: heights[i],
              rank: ranks[i],
              isFirst: ranks[i] == 1,
            ),
          )),
        ),
      ]),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.height,
    required this.rank,
    required this.isFirst,
  });
  final _LeaderEntry entry;
  final double height;
  final int rank;
  final bool isFirst;

  Color get _podiumColor => switch (rank) {
    1 => const Color(0xFFFFD700),
    2 => const Color(0xFFC0C0C0),
    _ => const Color(0xFFCD7F32),
  };

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Crown for rank 1
      if (isFirst) ...[
        const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
        const SizedBox(height: 4),
      ],
      // Avatar
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: Colors.white12,
          shape: BoxShape.circle,
          border: Border.all(color: _podiumColor, width: 2.5),
        ),
        child: const Icon(Icons.person, size: 26, color: Colors.white60),
      ),
      const SizedBox(height: 6),
      Text(
        entry.nama.split(' ').first,
        style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 11),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 2),
      Text('${entry.poin} pts',
        style: AppTypography.labelBold.copyWith(color: _podiumColor, fontSize: 10)),
      const SizedBox(height: 8),
      // Podium block
      Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: _podiumColor.withValues(alpha: 0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          border: Border.all(color: _podiumColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          '#$rank',
          style: AppTypography.headlineMd.copyWith(
            color: _podiumColor, fontWeight: FontWeight.w900),
        ),
      ),
    ]);
  }
}

class _MyRankBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Row(children: [
        const Icon(Icons.my_location, size: 18, color: AppColors.onPrimaryContainer),
        const SizedBox(width: 10),
        Text('Posisi kamu saat ini',
          style: AppTypography.bodyMd.copyWith(color: AppColors.onPrimaryContainer)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.onPrimaryContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
          ),
          child: Text('#3 dari 42',
            style: AppTypography.labelBold.copyWith(color: AppColors.primaryContainer)),
        ),
      ]),
    );
  }
}

class _LeaderCard extends StatelessWidget {
  const _LeaderCard({required this.entry, required this.isMe});
  final _LeaderEntry entry;
  final bool isMe;

  Color get _tierColor => switch (entry.tier) {
    'Gold'   => AppColors.secondaryContainer,
    'Silver' => AppColors.surfaceContainerHigh,
    _        => const Color(0xFFEDD5B3),
  };

  Color get _tierText => switch (entry.tier) {
    'Gold'   => AppColors.onSecondaryContainer,
    'Silver' => AppColors.onSurfaceVariant,
    _        => const Color(0xFF7B4F2E),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: AppColors.blackCharcoal,
          width: isMe ? 2.5 : 2,
        ),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Row(children: [
        // Rank number
        SizedBox(
          width: 32,
          child: Text(
            '#${entry.rank}',
            style: AppTypography.bodyLg.copyWith(
              fontWeight: FontWeight.w800,
              color: isMe ? AppColors.onPrimaryContainer : AppColors.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),
        // Avatar
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isMe ? AppColors.onPrimaryContainer.withValues(alpha: 0.15) : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
          ),
          child: Icon(Icons.person, size: 20,
            color: isMe ? AppColors.onPrimaryContainer : AppColors.tertiary),
        ),
        const SizedBox(width: 10),
        // Name & division
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
              child: Text(entry.nama,
                style: AppTypography.bodyMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isMe ? AppColors.onPrimaryContainer : AppColors.onSurface,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (isMe) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text('Kamu',
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.primaryContainer, fontSize: 9)),
              ),
            ],
          ]),
          Text(entry.divisi,
            style: AppTypography.labelBold.copyWith(
              color: isMe ? AppColors.onPrimaryContainer.withValues(alpha: 0.7) : AppColors.tertiary,
              fontSize: 10)),
        ])),
        const SizedBox(width: 8),
        // Tier badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _tierColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
          ),
          child: Text(entry.tier,
            style: AppTypography.labelBold.copyWith(color: _tierText, fontSize: 10)),
        ),
        const SizedBox(width: 8),
        // Points
        Text('${entry.poin}',
          style: AppTypography.bodyLg.copyWith(
            fontWeight: FontWeight.w800,
            color: isMe ? AppColors.onPrimaryContainer : AppColors.onSurface,
          )),
      ]),
    );
  }
}
