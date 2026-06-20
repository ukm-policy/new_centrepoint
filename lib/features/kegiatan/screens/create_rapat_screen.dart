import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../kegiatan_models.dart';
import '../rapat_models.dart';

// ── Mock Bidang & Sie data ────────────────────────────────────────────────────

const _kBidangList = ['Pemrograman', 'Jaringan', 'Multimedia', 'Pengembangan', 'Kaderisasi', 'Humas'];

// ── Screen ────────────────────────────────────────────────────────────────────

class CreateRapatScreen extends StatefulWidget {
  const CreateRapatScreen({super.key});

  @override
  State<CreateRapatScreen> createState() => _CreateRapatScreenState();
}

class _CreateRapatScreenState extends State<CreateRapatScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Step 1: Tipe (required first)
  RapatTipe? _tipe;

  // Step 2: Konteks
  String? _selectedKegiatanId;
  String? _selectedSie;
  String? _selectedBidang;
  bool _denganKetuaBidang = false;

  // Step 3: Info Dasar
  final _judulCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();
  final _waktuCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();

  // Step 4: Agenda (dynamic)
  final List<TextEditingController> _agendaCtrls = [];

  // Available tipes based on user's role
  List<RapatTipe> get _availableTipes {
    if (AppSession.isAdmin || AppSession.level >= 4) return RapatTipe.values;
    if (AppSession.level == 3) {
      // Ketua Bidang: bisa buat rapat internal bidang & rapat sie (jika panitia)
      return [RapatTipe.rapatInternalBidang, RapatTipe.rapatSie,
               RapatTipe.rapatUmumAcara, RapatTipe.rapatStakeholderAcara];
    }
    if (AppSession.level >= 1) {
      // Anggota umum: hanya rapat terkait sie/acara (jika panitia)
      return [RapatTipe.rapatSie, RapatTipe.rapatUmumAcara];
    }
    return [];
  }

  // Sie list from selected kegiatan
  List<String> get _sieFromKegiatan {
    if (_selectedKegiatanId == null) return [];
    return kKegiatanList
        .where((k) => k.id == _selectedKegiatanId)
        .expand((k) => k.sie.map((s) => s.namaSie))
        .toList();
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _tanggalCtrl.dispose();
    _waktuCtrl.dispose();
    _lokasiCtrl.dispose();
    for (final c in _agendaCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addAgenda() {
    setState(() => _agendaCtrls.add(TextEditingController()));
  }

  void _removeAgenda(int i) {
    setState(() {
      _agendaCtrls[i].dispose();
      _agendaCtrls.removeAt(i);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      _tanggalCtrl.text = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    }
  }

  Future<void> _submit() async {
    if (_tipe == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tipe rapat terlebih dahulu')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapat berhasil dibuat!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginPage, 16, AppSpacing.marginPage, 0,
              ),
              child: Row(children: [
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : context.go('/kegiatan'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      border: Border.all(color: AppColors.blackCharcoal, width: 2),
                      boxShadow: const [AppColors.hardShadowSm],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.arrow_back, size: 16, color: AppColors.onSurface),
                      const SizedBox(width: 6),
                      Text('Kembali', style: AppTypography.labelBold),
                    ]),
                  ),
                ),
                const Spacer(),
                Text('Buat Rapat', style: AppTypography.headlineSm),
              ]),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginPage, 0, AppSpacing.marginPage, 32),
                  children: [

                    // ── Seksi 1: Tipe Rapat ──────────────────────────────────
                    _SectionCard(
                      icon: Icons.tune_outlined,
                      title: 'Tipe Rapat',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pilih jenis rapat yang akan dibuat:',
                            style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                          const SizedBox(height: 12),
                          ..._availableTipes.map((tipe) => _TipeOption(
                            tipe: tipe,
                            selected: _tipe == tipe,
                            onTap: () => setState(() {
                              _tipe = tipe;
                              _selectedKegiatanId = null;
                              _selectedSie = null;
                              _selectedBidang = null;
                            }),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),

                    // ── Seksi 2: Konteks (conditional) ──────────────────────
                    if (_tipe != null) ...[
                      _SectionCard(
                        icon: Icons.link_outlined,
                        title: 'Konteks',
                        child: _buildKonteksSection(),
                      ),
                      const SizedBox(height: AppSpacing.stackGap),
                    ],

                    // ── Seksi 3: Info Dasar ──────────────────────────────────
                    _SectionCard(
                      icon: Icons.info_outline,
                      title: 'Informasi Dasar',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(label: 'JUDUL RAPAT'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _judulCtrl,
                            textCapitalization: TextCapitalization.sentences,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Rapat Koordinasi Seminar ...',
                              prefixIcon: Icon(Icons.meeting_room_outlined, size: 20),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
                          ),
                          const SizedBox(height: AppSpacing.stackGap),

                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(
                              flex: 3,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel(label: 'TANGGAL'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _tanggalCtrl,
                                    readOnly: true,
                                    onTap: _pickDate,
                                    style: AppTypography.bodyMd,
                                    decoration: const InputDecoration(
                                      hintText: 'Pilih tanggal',
                                      prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? 'Tanggal wajib' : null,
                                  ),
                                ]),
                            ),
                            const SizedBox(width: AppSpacing.gutterGrid),
                            Expanded(
                              flex: 2,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FieldLabel(label: 'WAKTU'),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _waktuCtrl,
                                    style: AppTypography.bodyMd,
                                    decoration: const InputDecoration(
                                      hintText: '19.00 WIB',
                                      prefixIcon: Icon(Icons.access_time_outlined, size: 18),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? 'Wajib' : null,
                                  ),
                                ]),
                            ),
                          ]),
                          const SizedBox(height: AppSpacing.stackGap),

                          const _FieldLabel(label: 'LOKASI / LINK'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _lokasiCtrl,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Ruang Sekretariat / Zoom Meeting / ...',
                              prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Lokasi wajib diisi' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),

                    // ── Seksi 4: Agenda ──────────────────────────────────────
                    _SectionCard(
                      icon: Icons.format_list_bulleted_outlined,
                      title: 'Agenda',
                      trailing: Text('${_agendaCtrls.length} poin',
                        style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_agendaCtrls.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('Belum ada agenda. Tambahkan poin agenda rapat.',
                                style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                            ),

                          ..._agendaCtrls.asMap().entries.map((e) {
                            final i = e.key;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(children: [
                                Container(
                                  width: 24, height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.blackCharcoal, width: 1.5),
                                  ),
                                  child: Center(child: Text('${i + 1}',
                                    style: AppTypography.labelBold.copyWith(
                                      color: AppColors.onPrimaryContainer, fontSize: 10))),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: e.value,
                                    textCapitalization: TextCapitalization.sentences,
                                    style: AppTypography.bodyMd,
                                    decoration: InputDecoration(
                                      hintText: 'Poin agenda ${i + 1}',
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _removeAgenda(i),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorContainer,
                                      borderRadius:
                                          BorderRadius.circular(AppSpacing.radiusSm),
                                      border: Border.all(
                                        color: AppColors.blackCharcoal, width: 1.5),
                                    ),
                                    child: const Icon(Icons.close, size: 14,
                                      color: AppColors.onErrorContainer),
                                  ),
                                ),
                              ]),
                            );
                          }),

                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _addAgenda,
                            child: Row(children: [
                              const Icon(Icons.add, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text('Tambah Poin Agenda',
                                style: AppTypography.labelBold.copyWith(
                                  color: AppColors.primary)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Submit ───────────────────────────────────────────────
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : BrutalistButton(
                            label: 'BUAT RAPAT',
                            icon: Icons.check_circle_outline,
                            onPressed: _submit,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKonteksSection() {
    final tipe = _tipe!;

    switch (tipe) {
      case RapatTipe.rapatUmumAcara:
      case RapatTipe.rapatStakeholderAcara:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _FieldLabel(label: 'TERKAIT ACARA'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedKegiatanId,
            onChanged: (v) => setState(() {
              _selectedKegiatanId = v;
              _selectedSie = null;
            }),
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
            decoration: const InputDecoration(
              hintText: 'Pilih acara/event',
              prefixIcon: Icon(Icons.event_outlined, size: 20),
            ),
            items: kKegiatanList.map((k) => DropdownMenuItem(
              value: k.id,
              child: Text(k.title, overflow: TextOverflow.ellipsis),
            )).toList(),
            validator: (v) => v == null ? 'Pilih acara terkait' : null,
          ),
        ]);

      case RapatTipe.rapatSie:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _FieldLabel(label: 'TERKAIT ACARA'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedKegiatanId,
            onChanged: (v) => setState(() {
              _selectedKegiatanId = v;
              _selectedSie = null;
            }),
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
            decoration: const InputDecoration(
              hintText: 'Pilih acara/event',
              prefixIcon: Icon(Icons.event_outlined, size: 20),
            ),
            items: kKegiatanList.map((k) => DropdownMenuItem(
              value: k.id,
              child: Text(k.title, overflow: TextOverflow.ellipsis),
            )).toList(),
            validator: (v) => v == null ? 'Pilih acara terkait' : null,
          ),
          if (_selectedKegiatanId != null) ...[
            const SizedBox(height: AppSpacing.stackGap),
            const _FieldLabel(label: 'SIE'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedSie,
              onChanged: (v) => setState(() => _selectedSie = v),
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
              decoration: const InputDecoration(
                hintText: 'Pilih sie',
                prefixIcon: Icon(Icons.workspaces_outlined, size: 20),
              ),
              items: _sieFromKegiatan.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s),
              )).toList(),
              validator: (v) => v == null ? 'Pilih sie' : null,
            ),
          ],
        ]);

      case RapatTipe.rapatStakeholderOrg:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Peserta otomatis: Ketua Umum, Sekretaris Umum, Bendahara Umum.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => setState(() => _denganKetuaBidang = !_denganKetuaBidang),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44, height: 24,
                decoration: BoxDecoration(
                  color: _denganKetuaBidang
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blackCharcoal, width: 2),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 150),
                  alignment: _denganKetuaBidang
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 18, height: 18,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: _denganKetuaBidang
                          ? AppColors.onPrimaryContainer
                          : AppColors.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Dengan Ketua Bidang',
                    style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                  Text('Semua Ketua Bidang akan diundang',
                    style: AppTypography.labelBold.copyWith(
                      color: AppColors.tertiary, fontSize: 11)),
                ]),
              ),
            ]),
          ),
        ]);

      case RapatTipe.rapatInternalBidang:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _FieldLabel(label: 'BIDANG'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedBidang,
            onChanged: (v) => setState(() => _selectedBidang = v),
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
            decoration: const InputDecoration(
              hintText: 'Pilih bidang',
              prefixIcon: Icon(Icons.workspaces_outlined, size: 20),
            ),
            items: _kBidangList.map((b) => DropdownMenuItem(
              value: b,
              child: Text('Bidang $b'),
            )).toList(),
            validator: (v) => v == null ? 'Pilih bidang' : null,
          ),
        ]);
    }
  }
}

// ── Tipe Option Card ──────────────────────────────────────────────────────────

class _TipeOption extends StatelessWidget {
  const _TipeOption({
    required this.tipe,
    required this.selected,
    required this.onTap,
  });
  final RapatTipe tipe;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? tipe.badgeColor.withAlpha(30) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(
            color: selected ? tipe.badgeColor : AppColors.borderSlate,
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected ? const [AppColors.hardShadowSm] : null,
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: selected ? tipe.badgeColor : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
            ),
            child: Icon(tipe.icon, size: 18,
              color: selected ? tipe.badgeTextColor : AppColors.tertiary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tipe.label, style: AppTypography.bodyLg.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
              Text(tipe.description, style: AppTypography.labelBold.copyWith(
                color: AppColors.tertiary, fontSize: 11)),
            ]),
          ),
          if (selected)
            Icon(Icons.check_circle, size: 20,
              color: tipe.badgeColor == AppColors.blackCharcoal
                  ? AppColors.success
                  : tipe.badgeColor),
        ]),
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: AppTypography.headlineSm),
          if (trailing != null) ...[const Spacer(), trailing!],
        ]),
        const SizedBox(height: 12),
        const MyDivider(color: AppColors.borderSlate, height: 12),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: AppTypography.labelBold.copyWith(
      color: AppColors.onSurface, letterSpacing: 0.5),
  );
}
