import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/models/kegiatan_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/repositories/kegiatan_repository.dart';
import '../../../data/repositories/member_repository.dart';

// ── Sie Form Entry ─────────────────────────────────────────────────────────────

class _SieEntry {
  _SieEntry() {
    namaCtrl = TextEditingController();
  }
  late final TextEditingController namaCtrl;
  MemberModel? selectedKetua;
  final List<MemberModel> selectedAnggota = [];

  void dispose() => namaCtrl.dispose();
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CreateKegiatanScreen extends StatefulWidget {
  const CreateKegiatanScreen({super.key});

  @override
  State<CreateKegiatanScreen> createState() => _CreateKegiatanScreenState();
}

class _CreateKegiatanScreenState extends State<CreateKegiatanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Info dasar
  final _namaCtrl = TextEditingController();
  final _tanggalCtrl = TextEditingController();
  final _waktuCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _kuotaCtrl = TextEditingController();

  // Panitia inti — pilih dari daftar member
  MemberModel? _selectedKetua;
  MemberModel? _selectedSekretaris;
  MemberModel? _selectedBendahara;

  // Sie
  final List<_SieEntry> _sieList = [];
  DateTime? _pickedDateRaw;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _tanggalCtrl.dispose();
    _waktuCtrl.dispose();
    _lokasiCtrl.dispose();
    _deskripsiCtrl.dispose();
    _kuotaCtrl.dispose();
    for (final sie in _sieList) {
      sie.dispose();
    }
    super.dispose();
  }

  void _addSie() => setState(() => _sieList.add(_SieEntry()));

  void _removeSie(int index) {
    setState(() {
      _sieList[index].dispose();
      _sieList.removeAt(index);
    });
  }

  Future<void> _pickMember({
    required String label,
    required MemberModel? current,
    required void Function(MemberModel?) onSelected,
  }) async {
    final members = context.read<MemberRepository>().members;
    final result = await showModalBottomSheet<MemberModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemberPickerSheet(
        label: label,
        members: members,
        selected: current,
      ),
    );
    if (result != null || current != null) {
      setState(() => onSelected(result));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKetua == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ketua Pelaksana wajib dipilih')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final kegiatanRepo = context.read<KegiatanRepository>();
    final newId = (kegiatanRepo.kegiatan.length + 1).toString();

    PanitiaModel toPanitia(MemberModel m) =>
        PanitiaModel(memberId: m.id, nama: m.nama, nim: m.nim);

    final sieListMapped = _sieList.map((s) => SieModel(
      namaSie: s.namaCtrl.text.trim(),
      ketua: s.selectedKetua != null ? toPanitia(s.selectedKetua!) : null,
      anggota: s.selectedAnggota.map(toPanitia).toList(),
    )).toList();

    kegiatanRepo.addKegiatan(KegiatanModel(
      id: newId,
      judul: _namaCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim(),
      tanggal: _pickedDateRaw ?? DateTime.now(),
      waktu: _waktuCtrl.text.trim(),
      lokasi: _lokasiCtrl.text.trim(),
      status: 'Akan Datang',
      kuota: int.tryParse(_kuotaCtrl.text.trim()) ?? 0,
      pesertaTerdaftar: 0,
      ketuaPelaksana: _selectedKetua != null ? toPanitia(_selectedKetua!) : null,
      sekretarisPelaksana: _selectedSekretaris != null ? toPanitia(_selectedSekretaris!) : null,
      bendaharaPelaksana: _selectedBendahara != null ? toPanitia(_selectedBendahara!) : null,
      sie: sieListMapped,
      periodeId: 'p-1',
    ));

    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kegiatan berhasil dibuat!')),
    );
    context.pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _pickedDateRaw = picked;
      final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
                      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
      setState(() {
        _tanggalCtrl.text = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allMembers = context.read<MemberRepository>().members;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────────
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
                Text('Buat Kegiatan', style: AppTypography.headlineSm),
              ]),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginPage, 0, AppSpacing.marginPage, 32,
                  ),
                  children: [

                    // ── Seksi 1: Informasi Dasar ─────────────────────────────
                    _SectionCard(
                      icon: Icons.info_outline,
                      title: 'Informasi Dasar',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(label: 'NAMA KEGIATAN'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _namaCtrl,
                            textCapitalization: TextCapitalization.words,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Seminar Kebijakan Publik',
                              prefixIcon: Icon(Icons.event_outlined, size: 20),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Nama kegiatan wajib diisi' : null,
                          ),
                          const SizedBox(height: AppSpacing.stackGap),

                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(
                              flex: 3,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                      (v == null || v.isEmpty) ? 'Tanggal wajib diisi' : null,
                                ),
                              ]),
                            ),
                            const SizedBox(width: AppSpacing.gutterGrid),
                            Expanded(
                              flex: 2,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const _FieldLabel(label: 'WAKTU'),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _waktuCtrl,
                                  style: AppTypography.bodyMd,
                                  decoration: const InputDecoration(
                                    hintText: '09.00 WIB',
                                    prefixIcon: Icon(Icons.access_time_outlined, size: 18),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.isEmpty) ? 'Wajib' : null,
                                ),
                              ]),
                            ),
                          ]),
                          const SizedBox(height: AppSpacing.stackGap),

                          const _FieldLabel(label: 'LOKASI'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _lokasiCtrl,
                            textCapitalization: TextCapitalization.words,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Aula Utama Kampus / Zoom Meeting',
                              prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Lokasi wajib diisi' : null,
                          ),
                          const SizedBox(height: AppSpacing.stackGap),

                          const _FieldLabel(label: 'DESKRIPSI'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _deskripsiCtrl,
                            minLines: 3,
                            maxLines: 6,
                            style: AppTypography.bodyMd,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Jelaskan tujuan dan detail kegiatan...',
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(bottom: 52),
                                child: Icon(Icons.notes_outlined, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.stackGap),

                          const _FieldLabel(label: 'KUOTA PESERTA'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _kuotaCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: '50',
                              prefixIcon: Icon(Icons.group_outlined, size: 20),
                              suffixText: 'orang',
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Kuota wajib diisi';
                              final n = int.tryParse(v);
                              if (n == null || n < 1) return 'Kuota tidak valid';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),

                    // ── Seksi 2: Panitia Inti ────────────────────────────────
                    _SectionCard(
                      icon: Icons.groups_outlined,
                      title: 'Panitia Inti',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FieldLabel(label: 'KETUA PELAKSANA'),
                          const SizedBox(height: 6),
                          _MemberPickerField(
                            selected: _selectedKetua,
                            placeholder: 'Pilih ketua pelaksana',
                            isRequired: true,
                            onTap: () => _pickMember(
                              label: 'Ketua Pelaksana',
                              current: _selectedKetua,
                              onSelected: (m) => _selectedKetua = m,
                            ),
                            onClear: () => setState(() => _selectedKetua = null),
                          ),
                          const SizedBox(height: AppSpacing.stackGap),

                          const _FieldLabel(label: 'SEKRETARIS PELAKSANA'),
                          const SizedBox(height: 6),
                          _MemberPickerField(
                            selected: _selectedSekretaris,
                            placeholder: 'Pilih sekretaris pelaksana',
                            onTap: () => _pickMember(
                              label: 'Sekretaris Pelaksana',
                              current: _selectedSekretaris,
                              onSelected: (m) => _selectedSekretaris = m,
                            ),
                            onClear: () => setState(() => _selectedSekretaris = null),
                          ),
                          const SizedBox(height: AppSpacing.stackGap),

                          const _FieldLabel(label: 'BENDAHARA PELAKSANA'),
                          const SizedBox(height: 6),
                          _MemberPickerField(
                            selected: _selectedBendahara,
                            placeholder: 'Pilih bendahara pelaksana',
                            onTap: () => _pickMember(
                              label: 'Bendahara Pelaksana',
                              current: _selectedBendahara,
                              onSelected: (m) => _selectedBendahara = m,
                            ),
                            onClear: () => setState(() => _selectedBendahara = null),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),

                    // ── Seksi 3: Susunan Sie ─────────────────────────────────
                    _SectionCard(
                      icon: Icons.account_tree_outlined,
                      title: 'Susunan Sie',
                      trailing: Text('${_sieList.length} Sie',
                        style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_sieList.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(AppSpacing.radius),
                                border: Border.all(color: AppColors.borderSlate, width: 1.5),
                              ),
                              child: Text(
                                'Belum ada Sie. Tambahkan seksi-seksi yang dibutuhkan.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                              ),
                            ),

                          ..._sieList.asMap().entries.map((entry) {
                            final i = entry.key;
                            final sie = entry.value;
                            return _SieFormCard(
                              index: i,
                              entry: sie,
                              members: allMembers,
                              onRemove: () => _removeSie(i),
                              onChanged: () => setState(() {}),
                            );
                          }),

                          const SizedBox(height: 12),
                          _AddSieButton(onTap: _addSie),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Submit ───────────────────────────────────────────────
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : BrutalistButton(
                            label: 'BUAT KEGIATAN',
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
}

// ── Member Picker Field ───────────────────────────────────────────────────────

class _MemberPickerField extends StatelessWidget {
  const _MemberPickerField({
    required this.selected,
    required this.placeholder,
    required this.onTap,
    required this.onClear,
    this.isRequired = false,
  });
  final MemberModel? selected;
  final String placeholder;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final hasValue = selected != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.primaryContainer.withValues(alpha: 0.3)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(
            color: hasValue ? AppColors.primary : AppColors.borderSlate,
            width: hasValue ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasValue ? Icons.person : Icons.person_search_outlined,
              size: 20,
              color: hasValue ? AppColors.primary : AppColors.tertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: hasValue
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected!.nama,
                          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${selected!.nim} · ${selected!.bidang ?? selected!.role}',
                          style: AppTypography.bodyMd.copyWith(
                              fontSize: 11, color: AppColors.tertiary),
                        ),
                      ],
                    )
                  : Text(placeholder,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
            ),
            if (hasValue)
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.close, size: 16, color: AppColors.tertiary),
                ),
              )
            else ...[
              if (isRequired)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('wajib',
                    style: AppTypography.labelBold.copyWith(
                        fontSize: 9, color: AppColors.onErrorContainer)),
                ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Member Picker Bottom Sheet ────────────────────────────────────────────────

class _MemberPickerSheet extends StatefulWidget {
  const _MemberPickerSheet({
    required this.label,
    required this.members,
    required this.selected,
    this.excluded = const [],
  });
  final String label;
  final List<MemberModel> members;
  // Single selected (for panitia inti & ketua sie)
  final MemberModel? selected;
  // Already-picked ids to grey out (for anggota sie)
  final List<String> excluded;

  @override
  State<_MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends State<_MemberPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MemberModel> get _filtered {
    final available = widget.members
        .where((m) => !widget.excluded.contains(m.id))
        .toList();
    if (_query.isEmpty) return available;
    final q = _query.toLowerCase();
    return available.where((m) =>
      m.nama.toLowerCase().contains(q) ||
      m.nim.toLowerCase().contains(q) ||
      (m.bidang?.toLowerCase().contains(q) ?? false),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(color: AppColors.blackCharcoal, width: 2),
            left: BorderSide(color: AppColors.blackCharcoal, width: 2),
            right: BorderSide(color: AppColors.blackCharcoal, width: 2),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderSlate,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginPage, 8, AppSpacing.marginPage, 12),
              child: Row(
                children: [
                  Text(
                    'Pilih ${widget.label}',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, size: 20, color: AppColors.onSurface),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: AppTypography.bodyMd,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Cari nama atau NIM...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                          child: const Icon(Icons.close, size: 16),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
              child: Text(
                '${filtered.length} anggota',
                style: AppTypography.labelBold.copyWith(
                    color: AppColors.tertiary, fontSize: 10, letterSpacing: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            const MyDivider(color: AppColors.borderSlate),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('Tidak ada anggota ditemukan',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                    )
                  : ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.marginPage, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const MyDivider(color: AppColors.borderSlate, height: 4),
                      itemBuilder: (_, i) {
                        final m = filtered[i];
                        final isSelected = widget.selected?.id == m.id;
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop(m),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            color: Colors.transparent,
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryContainer
                                        : AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.blackCharcoal,
                                      width: isSelected ? 2 : 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      m.nama.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                                      style: AppTypography.labelBold.copyWith(
                                        fontSize: 12,
                                        color: isSelected
                                            ? AppColors.onPrimaryContainer
                                            : AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m.nama,
                                        style: AppTypography.bodyMd.copyWith(
                                            fontWeight: FontWeight.bold)),
                                      Text(
                                        '${m.nim} · ${m.bidang ?? m.role}',
                                        style: AppTypography.bodyMd.copyWith(
                                            fontSize: 11, color: AppColors.tertiary),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      size: 18, color: AppColors.primary),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sie Form Card ─────────────────────────────────────────────────────────────

class _SieFormCard extends StatefulWidget {
  const _SieFormCard({
    required this.index,
    required this.entry,
    required this.members,
    required this.onRemove,
    required this.onChanged,
  });
  final int index;
  final _SieEntry entry;
  final List<MemberModel> members;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  State<_SieFormCard> createState() => _SieFormCardState();
}

class _SieFormCardState extends State<_SieFormCard> {
  Future<void> _pickKetua() async {
    // Exclude already-selected anggota from ketua picker
    final excluded = widget.entry.selectedAnggota.map((m) => m.id).toList();
    final result = await showModalBottomSheet<MemberModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemberPickerSheet(
        label: 'Ketua Sie',
        members: widget.members,
        selected: widget.entry.selectedKetua,
        excluded: excluded,
      ),
    );
    if (result != null) {
      setState(() => widget.entry.selectedKetua = result);
      widget.onChanged();
    }
  }

  Future<void> _pickAnggota() async {
    // Exclude ketua and already-picked anggota
    final excluded = [
      if (widget.entry.selectedKetua != null) widget.entry.selectedKetua!.id,
      ...widget.entry.selectedAnggota.map((m) => m.id),
    ];
    final result = await showModalBottomSheet<MemberModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemberPickerSheet(
        label: 'Anggota Sie',
        members: widget.members,
        selected: null,
        excluded: excluded,
      ),
    );
    if (result != null) {
      setState(() => widget.entry.selectedAnggota.add(result));
      widget.onChanged();
    }
  }

  void _removeAnggota(int i) {
    setState(() => widget.entry.selectedAnggota.removeAt(i));
    widget.onChanged();
  }

  void _clearKetua() {
    setState(() => widget.entry.selectedKetua = null);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.blackCharcoal,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text('SIE ${widget.index + 1}',
                style: AppTypography.labelBold.copyWith(
                    color: Colors.white, fontSize: 10, letterSpacing: 1)),
            ),
            const Spacer(),
            GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                ),
                child: const Icon(Icons.delete_outline, size: 16,
                    color: AppColors.onErrorContainer),
              ),
            ),
          ]),
          const SizedBox(height: 10),

          // Nama Sie
          const _FieldLabel(label: 'NAMA SIE'),
          const SizedBox(height: 4),
          TextFormField(
            controller: entry.namaCtrl,
            textCapitalization: TextCapitalization.words,
            style: AppTypography.bodyMd,
            decoration: const InputDecoration(
              hintText: 'Contoh: Sie Acara, Sie Konsumsi',
              prefixIcon: Icon(Icons.label_outline, size: 18),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nama Sie wajib diisi' : null,
          ),
          const SizedBox(height: AppSpacing.gutterGrid),

          // Ketua Sie
          const _FieldLabel(label: 'KETUA SIE'),
          const SizedBox(height: 4),
          _MemberPickerField(
            selected: entry.selectedKetua,
            placeholder: 'Pilih ketua sie',
            onTap: _pickKetua,
            onClear: _clearKetua,
          ),
          const SizedBox(height: AppSpacing.gutterGrid),

          // Anggota Sie
          Row(children: [
            const _FieldLabel(label: 'ANGGOTA SIE'),
            const Spacer(),
            Text('${entry.selectedAnggota.length} anggota',
              style: AppTypography.labelBold.copyWith(
                  color: AppColors.tertiary, fontSize: 10)),
          ]),
          const SizedBox(height: 6),

          if (entry.selectedAnggota.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('Belum ada anggota',
                style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
            ),

          ...entry.selectedAnggota.asMap().entries.map((e) {
            final j = e.key;
            final m = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                ),
                child: Row(children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                    ),
                    child: Center(
                      child: Text(
                        m.nama.split(' ').map((s) => s[0]).take(2).join().toUpperCase(),
                        style: AppTypography.labelBold.copyWith(fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.nama,
                        style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                      Text(m.nim,
                        style: AppTypography.bodyMd.copyWith(
                            fontSize: 11, color: AppColors.tertiary)),
                    ]),
                  ),
                  GestureDetector(
                    onTap: () => _removeAnggota(j),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                      ),
                      child: const Icon(Icons.close, size: 13,
                          color: AppColors.onErrorContainer),
                    ),
                  ),
                ]),
              ),
            );
          }),

          const SizedBox(height: 4),
          GestureDetector(
            onTap: _pickAnggota,
            child: Row(children: [
              const Icon(Icons.add, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text('Tambah Anggota',
                style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Add Sie Button ────────────────────────────────────────────────────────────

class _AddSieButton extends StatelessWidget {
  const _AddSieButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: const [AppColors.hardShadowSm],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Tambah Sie',
            style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: AppTypography.headlineSm),
            if (trailing != null) ...[
              const Spacer(),
              trailing!,
            ],
          ]),
          const SizedBox(height: 12),
          const MyDivider(color: AppColors.borderSlate, height: 12),
          const SizedBox(height: 12),
          child,
        ],
      ),
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
      color: AppColors.onSurface,
      letterSpacing: 0.5,
    ),
  );
}
