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
import '../../../data/repositories/kegiatan_repository.dart';

// ── Sie Form Entry ─────────────────────────────────────────────────────────────

class _SieEntry {
  _SieEntry() {
    namaCtrl = TextEditingController();
    ketuaCtrl = TextEditingController();
  }
  late final TextEditingController namaCtrl;
  late final TextEditingController ketuaCtrl;
  final List<TextEditingController> anggotaCtrls = [];

  void dispose() {
    namaCtrl.dispose();
    ketuaCtrl.dispose();
    for (final c in anggotaCtrls) {
      c.dispose();
    }
  }
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

  // Panitia inti
  final _ketuaCtrl = TextEditingController();
  final _sekretarisCtrl = TextEditingController();
  final _bendaharaCtrl = TextEditingController();

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
    _ketuaCtrl.dispose();
    _sekretarisCtrl.dispose();
    _bendaharaCtrl.dispose();
    for (final sie in _sieList) {
      sie.dispose();
    }
    super.dispose();
  }

  void _addSie() {
    setState(() => _sieList.add(_SieEntry()));
  }

  void _removeSie(int index) {
    setState(() {
      _sieList[index].dispose();
      _sieList.removeAt(index);
    });
  }

  void _addAnggota(int sieIndex) {
    setState(() => _sieList[sieIndex].anggotaCtrls.add(TextEditingController()));
  }

  void _removeAnggota(int sieIndex, int anggotaIndex) {
    setState(() {
      _sieList[sieIndex].anggotaCtrls[anggotaIndex].dispose();
      _sieList[sieIndex].anggotaCtrls.removeAt(anggotaIndex);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final kegiatanRepo = context.read<KegiatanRepository>();
    final newId = (kegiatanRepo.kegiatan.length + 1).toString();

    // Map Sie
    final List<SieModel> sieListMapped = [];
    for (final s in _sieList) {
      final membersList = s.anggotaCtrls
          .where((c) => c.text.trim().isNotEmpty)
          .map((c) => PanitiaModel(
                memberId: '',
                nama: c.text.trim(),
                nim: '',
              ))
          .toList();

      sieListMapped.add(
        SieModel(
          namaSie: s.namaCtrl.text.trim(),
          ketua: s.ketuaCtrl.text.trim().isEmpty
              ? null
              : PanitiaModel(memberId: '', nama: s.ketuaCtrl.text.trim(), nim: ''),
          anggota: membersList,
        ),
      );
    }

    final newKegiatan = KegiatanModel(
      id: newId,
      judul: _namaCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim(),
      tanggal: _pickedDateRaw ?? DateTime.now(),
      waktu: _waktuCtrl.text.trim(),
      lokasi: _lokasiCtrl.text.trim(),
      status: 'Akan Datang',
      kuota: int.tryParse(_kuotaCtrl.text.trim()) ?? 0,
      pesertaTerdaftar: 0,
      ketuaPelaksana: _ketuaCtrl.text.trim().isEmpty
          ? null
          : PanitiaModel(memberId: '', nama: _ketuaCtrl.text.trim(), nim: ''),
      sekretarisPelaksana: _sekretarisCtrl.text.trim().isEmpty
          ? null
          : PanitiaModel(memberId: '', nama: _sekretarisCtrl.text.trim(), nim: ''),
      bendaharaPelaksana: _bendaharaCtrl.text.trim().isEmpty
          ? null
          : PanitiaModel(memberId: '', nama: _bendaharaCtrl.text.trim(), nim: ''),
      sie: sieListMapped,
      periodeId: 'p-1',
    );

    kegiatanRepo.addKegiatan(newKegiatan);

    setState(() => _loading = false);
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
      _tanggalCtrl.text = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Text(
                  'Buat Kegiatan',
                  style: AppTypography.headlineSm,
                ),
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
                            // Tanggal
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
                            // Waktu
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
                          TextFormField(
                            controller: _ketuaCtrl,
                            textCapitalization: TextCapitalization.words,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Nama anggota',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Ketua Pelaksana wajib diisi' : null,
                          ),
                          const SizedBox(height: AppSpacing.stackGap),

                          const _FieldLabel(label: 'SEKRETARIS PELAKSANA'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _sekretarisCtrl,
                            textCapitalization: TextCapitalization.words,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Nama anggota',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.stackGap),

                          const _FieldLabel(label: 'BENDAHARA PELAKSANA'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _bendaharaCtrl,
                            textCapitalization: TextCapitalization.words,
                            style: AppTypography.bodyMd,
                            decoration: const InputDecoration(
                              hintText: 'Nama anggota',
                              prefixIcon: Icon(Icons.person_outline, size: 20),
                            ),
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
                                border: Border.all(
                                  color: AppColors.borderSlate,
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
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
                              onRemove: () => _removeSie(i),
                              onAddAnggota: () => _addAnggota(i),
                              onRemoveAnggota: (j) => _removeAnggota(i, j),
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

// ── Sie Form Card ─────────────────────────────────────────────────────────────

class _SieFormCard extends StatelessWidget {
  const _SieFormCard({
    required this.index,
    required this.entry,
    required this.onRemove,
    required this.onAddAnggota,
    required this.onRemoveAnggota,
    required this.onChanged,
  });
  final int index;
  final _SieEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onAddAnggota;
  final void Function(int) onRemoveAnggota;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
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
          // Sie header row
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.blackCharcoal,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text('SIE ${index + 1}', style: AppTypography.labelBold.copyWith(
                color: Colors.white, fontSize: 10, letterSpacing: 1)),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onRemove,
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
            onChanged: (_) => onChanged(),
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
          TextFormField(
            controller: entry.ketuaCtrl,
            textCapitalization: TextCapitalization.words,
            style: AppTypography.bodyMd,
            decoration: const InputDecoration(
              hintText: 'Nama ketua sie',
              prefixIcon: Icon(Icons.star_outline, size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.gutterGrid),

          // Anggota
          Row(children: [
            const _FieldLabel(label: 'ANGGOTA SIE'),
            const Spacer(),
            Text('${entry.anggotaCtrls.length} anggota',
              style: AppTypography.labelBold.copyWith(
                color: AppColors.tertiary, fontSize: 10)),
          ]),
          const SizedBox(height: 4),

          if (entry.anggotaCtrls.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('Belum ada anggota',
                style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
            ),

          ...entry.anggotaCtrls.asMap().entries.map((e) {
            final j = e.key;
            final ctrl = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: ctrl,
                    textCapitalization: TextCapitalization.words,
                    style: AppTypography.bodyMd,
                    decoration: InputDecoration(
                      hintText: 'Nama anggota ${j + 1}',
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => onRemoveAnggota(j),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                    ),
                    child: const Icon(Icons.close, size: 14,
                      color: AppColors.onErrorContainer),
                  ),
                ),
              ]),
            );
          }),
          const SizedBox(height: 4),

          // + Tambah Anggota
          GestureDetector(
            onTap: onAddAnggota,
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
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
          boxShadow: const [AppColors.hardShadowSm],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Tambah Sie', style: AppTypography.labelBold.copyWith(
            color: AppColors.primary)),
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
