import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/session/app_session.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/jabatan_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/periode_model.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/periode_repository.dart';
import '../../../shared/utils/feedback.dart';
import '../../../shared/utils/initials.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/list_status.dart';
import '../../../shared/widgets/my_divider.dart';

/// Atur jabatan tiap anggota untuk satu periode kepengurusan.
/// Jabatan diambil langsung dari tabel `jabatan`; disimpan ke `kepengurusan`.
class AssignJabatanScreen extends StatefulWidget {
  const AssignJabatanScreen({super.key});

  @override
  State<AssignJabatanScreen> createState() => _AssignJabatanScreenState();
}

class _AssignJabatanScreenState extends State<AssignJabatanScreen> {
  String? _periodeId;
  List<JabatanModel> _jabatan = [];

  /// Jabatan tersimpan di database (userId → jabatanId) untuk periode terpilih.
  Map<String, int> _saved = {};

  /// Perubahan yang belum disimpan (userId → jabatanId, null = tanpa jabatan).
  final Map<String, int?> _edits = {};

  bool _loading = true;
  bool _saving = false;
  Object? _error;
  String _search = '';

  /// Dinaikkan untuk memaksa dropdown periode kembali ke [_periodeId].
  int _periodeResetToken = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final periodeRepo = context.read<PeriodeRepository>();
    final active =
        periodeRepo.periodes.where((p) => p.isActive).firstOrNull ??
        periodeRepo.periodes.firstOrNull;
    _periodeId = active?.id;
    await _load();
  }

  Future<void> _load() async {
    final repo = context.read<MemberRepository>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final jabatan = _jabatan.isEmpty ? await repo.fetchJabatan() : _jabatan;
      final saved = _periodeId == null
          ? <String, int>{}
          : await repo.fetchKepengurusan(_periodeId!);
      if (!mounted) return;
      setState(() {
        _jabatan = jabatan;
        _saved = saved;
        _edits.clear();
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changePeriode(String? id) async {
    if (id == null || id == _periodeId) return;
    if (_edits.isNotEmpty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Buang perubahan?'),
          content: Text('${_edits.length} perubahan jabatan belum disimpan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Buang'),
            ),
          ],
        ),
      );
      if (discard != true) {
        setState(
          () => _periodeResetToken++,
        ); // kembalikan dropdown ke periode semula
        return;
      }
    }
    _periodeId = id;
    await _load();
  }

  int? _currentJabatan(String userId) =>
      _edits.containsKey(userId) ? _edits[userId] : _saved[userId];

  void _setJabatan(String userId, int? jabatanId) {
    setState(() {
      if (jabatanId == _saved[userId]) {
        _edits.remove(userId);
      } else {
        _edits[userId] = jabatanId;
      }
    });
  }

  Future<void> _save(List<MemberModel> members) async {
    final periodeId = _periodeId;
    if (periodeId == null || _edits.isEmpty) return;
    final memberRepo = context.read<MemberRepository>();
    final auditRepo = context.read<AuditLogRepository>();
    final namaById = {for (final m in members) m.id: m.nama};
    final jabatanById = {for (final j in _jabatan) j.id: j.nama};
    final ubahDiriSendiri = _edits.containsKey(AppSession.id);

    setState(() => _saving = true);
    final failed = <String>[];
    Object? lastError;
    for (final entry in _edits.entries.toList()) {
      try {
        await memberRepo.setJabatan(entry.key, periodeId, entry.value);
        _saved = {..._saved}..remove(entry.key);
        if (entry.value != null) _saved[entry.key] = entry.value!;
        _edits.remove(entry.key);
        auditRepo.logAction(
          aksi:
              'Mengatur jabatan ${namaById[entry.key] ?? entry.key}: '
              '${entry.value == null ? 'tanpa jabatan' : jabatanById[entry.value] ?? entry.value}',
          tipe: 'Sistem',
          entityId: entry.key,
          entityType: 'kepengurusan',
        );
      } catch (e) {
        failed.add(namaById[entry.key] ?? entry.key);
        lastError = e;
      }
    }
    if (!mounted) return;
    setState(() => _saving = false);
    memberRepo.reload();
    // Jabatan sendiri berubah → perbarui hak akses sesi.
    if (ubahDiriSendiri) SessionController.instance.reloadProfile();

    if (failed.isNotEmpty) {
      showErrorSnack(
        context,
        lastError!,
        prefix:
            'Gagal menyimpan ${failed.length} anggota (${failed.take(3).join(', ')})',
      );
    } else {
      showSuccessSnack(context, 'Jabatan berhasil disimpan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final periodes = context.watch<PeriodeRepository>().periodes;
    final members =
        context
            .watch<MemberRepository>()
            .members
            .where((m) => m.isActive)
            .toList()
          ..sort(
            (a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()),
          );
    final q = _search.toLowerCase();
    final filtered = members
        .where(
          (m) =>
              q.isEmpty ||
              m.nama.toLowerCase().contains(q) ||
              m.nim.contains(q),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: PageAppBar(
        title: 'Assign Jabatan',
        badgeCount: _edits.isEmpty ? null : _edits.length,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginPage,
                0,
                AppSpacing.marginPage,
                AppSpacing.stackGap,
              ),
              child: BrutalistCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.surfaceContainerLowest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERIODE KEPENGURUSAN',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.tertiary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PeriodeDropdown(
                      key: ValueKey(_periodeResetToken),
                      periodes: periodes,
                      value: _periodeId,
                      onChanged: _saving ? null : _changePeriode,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: AppTypography.bodyMd,
                      decoration: const InputDecoration(
                        hintText: 'Cari nama atau NIM...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _buildList(filtered, periodes)),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              child: _saving
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.blackCharcoal,
                      ),
                    )
                  : BrutalistButton(
                      label: _edits.isEmpty
                          ? 'TIDAK ADA PERUBAHAN'
                          : 'SIMPAN ${_edits.length} PERUBAHAN',
                      icon: Icons.save_outlined,
                      onPressed: _edits.isEmpty ? null : () => _save(members),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<MemberModel> members, List<PeriodeModel> periodes) {
    if (periodes.isEmpty && !_loading) {
      return const ListStatus(
        loading: false,
        icon: Icons.calendar_month_outlined,
        message:
            'Belum ada periode kepengurusan.\nBuat periode terlebih dahulu di menu Kelola Periode.',
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListStatus(
                loading: false,
                icon: Icons.cloud_off,
                message: 'Gagal memuat data jabatan.',
              ),
              BrutalistButton(
                label: 'COBA LAGI',
                icon: Icons.refresh,
                fullWidth: false,
                onPressed: _load,
              ),
            ],
          ),
        ),
      );
    }
    if (_loading || members.isEmpty) {
      return ListStatus(
        loading: _loading,
        icon: Icons.group_off_outlined,
        message: 'Tidak ada anggota aktif.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
      itemCount: members.length,
      itemBuilder: (context, i) {
        final m = members[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
          child: _MemberJabatanCard(
            member: m,
            jabatan: _jabatan,
            value: _currentJabatan(m.id),
            changed: _edits.containsKey(m.id),
            onChanged: _saving ? null : (v) => _setJabatan(m.id, v),
          ),
        );
      },
    );
  }
}

class _PeriodeDropdown extends StatelessWidget {
  const _PeriodeDropdown({
    super.key,
    required this.periodes,
    required this.value,
    required this.onChanged,
  });
  final List<PeriodeModel> periodes;
  final String? value;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final valid = periodes.any((p) => p.id == value);
    return DropdownButtonFormField<String>(
      key: ValueKey(valid ? value : null),
      initialValue: valid ? value : null,
      isExpanded: true,
      onChanged: onChanged,
      hint: const Text('Pilih periode'),
      style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        prefixIcon: Icon(Icons.date_range_outlined, size: 18),
      ),
      items: periodes
          .map(
            (p) => DropdownMenuItem(
              value: p.id,
              child: Text(
                p.isActive ? '${p.nama} (aktif)' : p.nama,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MemberJabatanCard extends StatelessWidget {
  const _MemberJabatanCard({
    required this.member,
    required this.jabatan,
    required this.value,
    required this.changed,
    required this.onChanged,
  });

  final MemberModel member;
  final List<JabatanModel> jabatan;
  final int? value;
  final bool changed;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    // Jabatan tersimpan yang tidak ada di daftar (mis. sudah dihapus) tetap ditampilkan.
    final known = value == null || jabatan.any((j) => j.id == value);
    return BrutalistCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: changed ? AppColors.highlightContainer : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Text(
                  initialsOf(member.nama),
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'NIM ${member.nim}',
                      style: AppTypography.labelBold.copyWith(
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (changed)
                Text(
                  'Diubah',
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.onHighlightContainer,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const MyDivider(color: AppColors.borderSlate),
          const SizedBox(height: 12),
          Text(
            'JABATAN',
            style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<int?>(
            key: ValueKey('${member.id}-$value'),
            initialValue: value,
            isExpanded: true,
            onChanged: onChanged,
            style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tanpa jabatan (anggota)'),
              ),
              if (!known)
                DropdownMenuItem<int?>(
                  value: value,
                  child: Text('Jabatan #$value (tidak ditemukan)'),
                ),
              ...jabatan.map(
                (j) => DropdownMenuItem<int?>(
                  value: j.id,
                  child: Text(j.label, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
