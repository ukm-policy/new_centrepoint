import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/models/kegiatan_model.dart';
import '../../../data/models/rapat_model.dart';
import '../../../data/repositories/kegiatan_repository.dart';
import '../../../data/repositories/rapat_repository.dart';
import '../../../shared/utils/feedback.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../shared/widgets/missing_data_screen.dart';

// ── Mock Bidang & Sie data ────────────────────────────────────────────────────

const _kBidangList = ['Pemrograman', 'Jaringan', 'Multimedia', 'Pengembangan', 'Kaderisasi', 'Humas'];

// ── Screen ────────────────────────────────────────────────────────────────────

class CreateRapatScreen extends StatefulWidget {
  const CreateRapatScreen({super.key, this.editId});

  /// Diisi untuk mode edit: id rapat yang diubah.
  final String? editId;

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
  DateTime? _pickedDateRaw;

  // Mode edit
  bool get _isEdit => widget.editId != null;
  RapatModel? _editing;
  RapatStatus _status = RapatStatus.terjadwal;
  bool _prefillScheduled = false;

  static const _namaBulan = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

  /// Isi form dari rapat yang sedang diedit.
  void _prefill(RapatModel r) {
    setState(() {
      _editing = r;
      _status = r.status;
      _tipe = r.tipe;
      _selectedKegiatanId = r.kegiatanId;
      _selectedSie = r.namaSie;
      _selectedBidang = r.namaBidang;
      _denganKetuaBidang = r.denganKetuaBidang;
      _judulCtrl.text = r.judul;
      _waktuCtrl.text = r.waktu;
      _lokasiCtrl.text = r.lokasi;
      _pickedDateRaw = r.tanggal;
      _tanggalCtrl.text = '${r.tanggal.day} ${_namaBulan[r.tanggal.month - 1]} ${r.tanggal.year}';
      for (final c in _agendaCtrls) {
        c.dispose();
      }
      _agendaCtrls
        ..clear()
        ..addAll(r.agenda.map((a) => TextEditingController(text: a.judul)));
    });
  }

  // Available tipes based on user's role
  List<RapatTipe> get _availableTipes {
    final tipes = _tipesForRole;
    final current = _editing?.tipe;
    return current == null || tipes.contains(current) ? tipes : [current, ...tipes];
  }

  List<RapatTipe> get _tipesForRole {
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

  List<String> _sieFromKegiatan(String? kegiatanId, List<KegiatanModel> kegiatanList) {
    if (kegiatanId == null) return [];
    return kegiatanList
        .where((k) => k.id == kegiatanId)
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
    final now = DateTime.now();
    final current = _pickedDateRaw;
    final first = current != null && current.isBefore(now) ? current : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now.add(const Duration(days: 1)),
      firstDate: first,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _pickedDateRaw = picked;
      final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
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

    final rapatRepo = context.read<RapatRepository>();

    // Map agenda items
    final agendaList = _agendaCtrls
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => AgendaModel(
              judul: c.text.trim(),
              keterangan: _editing?.agenda
                  .where((a) => a.judul == c.text.trim())
                  .firstOrNull
                  ?.keterangan,
            ))
        .toList();

    // Peserta = ID anggota (rapat_peserta.member_id), sesuai tipe rapat.
    final members = context.read<MemberRepository>().members.where((m) => m.isActive);
    final peserta = <String>{};
    if (_tipe == RapatTipe.rapatStakeholderOrg) {
      peserta.addAll(members.where((m) => m.level >= 4).map((m) => m.id));
      if (_denganKetuaBidang) {
        peserta.addAll(members.where((m) => m.level == 3).map((m) => m.id));
      }
    } else if (_tipe == RapatTipe.rapatInternalBidang) {
      peserta.addAll(members.where((m) => m.bidang == _selectedBidang).map((m) => m.id));
    } else {
      // Rapat acara: ambil dari panitia kegiatan.
      final kegiatanList = context.read<KegiatanRepository>().kegiatan;
      final k = kegiatanList.where((k) => k.id == _selectedKegiatanId).firstOrNull;
      if (k != null) {
        final inti = [k.ketuaPelaksana, k.sekretarisPelaksana, k.bendaharaPelaksana]
            .whereType<PanitiaModel>();
        if (_tipe == RapatTipe.rapatStakeholderAcara) {
          peserta.addAll(inti.map((p) => p.memberId));
        } else if (_tipe == RapatTipe.rapatUmumAcara) {
          peserta.addAll(inti.map((p) => p.memberId));
          for (final s in k.sie) {
            if (s.ketua != null) peserta.add(s.ketua!.memberId);
            peserta.addAll(s.anggota.map((a) => a.memberId));
          }
        } else if (_tipe == RapatTipe.rapatSie) {
          final s = k.sie.where((s) => s.namaSie == _selectedSie).firstOrNull;
          if (s != null) {
            if (s.ketua != null) peserta.add(s.ketua!.memberId);
            peserta.addAll(s.anggota.map((a) => a.memberId));
          }
        }
      }
    }
    peserta.remove('');

    final newRapat = RapatModel(
      id: _editing?.id ?? '',
      judul: _judulCtrl.text.trim(),
      tipe: _tipe!,
      status: _isEdit ? _status : RapatStatus.terjadwal,
      notulensi: _editing?.notulensi,
      tanggal: _pickedDateRaw ?? DateTime.now(),
      waktu: _waktuCtrl.text.trim(),
      lokasi: _lokasiCtrl.text.trim(),
      agenda: agendaList,
      pesertaIds: peserta.toList(),
      kegiatanId: _selectedKegiatanId,
      namaSie: _selectedSie,
      namaBidang: _selectedBidang,
      denganKetuaBidang: _denganKetuaBidang,
    );

    final ok = await runWithFeedback(
      context,
      () => _isEdit ? rapatRepo.updateRapat(newRapat) : rapatRepo.addRapat(newRapat),
      success: _isEdit ? 'Perubahan rapat disimpan!' : 'Rapat berhasil dibuat!',
      errorPrefix: _isEdit ? 'Gagal menyimpan rapat' : 'Gagal membuat rapat',
    );

    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final kegiatanList = context.watch<KegiatanRepository>().kegiatan;

    if (_isEdit && _editing == null) {
      final rapatRepo = context.watch<RapatRepository>();
      final target = rapatRepo.rapat.where((r) => r.id == widget.editId).firstOrNull;
      if (target == null) {
        return MissingDataScreen(title: 'Edit Rapat', loading: rapatRepo.isLoading);
      }
      if (!_prefillScheduled) {
        _prefillScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _prefill(target);
        });
      }
    }
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Column(
          children: [
            FloatingAppBar(
              title: _isEdit ? 'Edit Rapat' : 'Buat Rapat',
              showBack: true,
              trailing: SizedBox(width: 40),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginPage, 0, AppSpacing.marginPage, 32),
                  children: [

                    // ── Status (hanya saat edit) ─────────────────────────────
                    if (_isEdit) ...[
                      _SectionCard(
                        icon: Icons.flag_outlined,
                        title: 'Status Rapat',
                        child: DropdownButtonFormField<RapatStatus>(
                          key: ValueKey(_status),
                          initialValue: _status,
                          onChanged: (v) => setState(() => _status = v ?? _status),
                          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                          items: RapatStatus.values
                              .map((st) => DropdownMenuItem(value: st, child: Text(st.label)))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackGap),
                    ],

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
                        child: _buildKonteksSection(kegiatanList),
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
                            label: _isEdit ? 'SIMPAN PERUBAHAN' : 'BUAT RAPAT',
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

  Widget _buildKonteksSection(List<KegiatanModel> kegiatanList) {
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
            items: kegiatanList.map((k) => DropdownMenuItem(
              value: k.id,
              child: Text(k.judul, overflow: TextOverflow.ellipsis),
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
            items: kegiatanList.map((k) => DropdownMenuItem(
              value: k.id,
              child: Text(k.judul, overflow: TextOverflow.ellipsis),
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
              items: _sieFromKegiatan(_selectedKegiatanId, kegiatanList).map((s) => DropdownMenuItem(
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
            items: {
              ..._kBidangList,
              // Bidang yang benar-benar dipakai anggota (nama dari database).
              ...context
                  .read<MemberRepository>()
                  .members
                  .map((m) => m.bidang)
                  .whereType<String>()
                  .where((b) => b.isNotEmpty && b != '-'),
            }.map((b) => DropdownMenuItem(
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
