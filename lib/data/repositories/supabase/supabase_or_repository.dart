import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/or_model.dart';
import '../or_repository.dart';

class SupabaseORRepository extends ORRepository {
  final _db = Supabase.instance.client;
  ORPeriodeModel _periode = ORPeriodeModel(
    id: '',
    nama: 'Open Recruitment',
    tanggalBuka: DateTime.now(),
    tanggalTutup: DateTime.now().add(const Duration(days: 7)),
    kuota: 0,
    deskripsi: '',
    bidangTersedia: const [],
    isManuallyOpen: false,
  );
  List<ORApplicantModel> _applicants = [];

  SupabaseORRepository() {
    _loadORData();
    _db
        .channel('public:or_periode')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'or_periode',
          callback: (payload) {
            _loadORData();
          },
        )
        .subscribe();
    _db
        .channel('public:or_pelamar')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'or_pelamar',
          callback: (payload) {
            _loadORData();
          },
        )
        .subscribe();
  }

  Future<void> _loadORData() async {
    try {
      // 1. Fetch active/latest period
      final periodRes = await _db.from('or_periode').select().order('created_at', ascending: false).limit(1);
      if (periodRes.isNotEmpty) {
        final json = periodRes.first;
        _periode = ORPeriodeModel(
          id: json['id'] as String,
          nama: json['nama'] as String? ?? '',
          tanggalBuka: DateTime.tryParse(json['tanggal_buka'] ?? '') ?? DateTime.now(),
          tanggalTutup: DateTime.tryParse(json['tanggal_tutup'] ?? '') ?? DateTime.now(),
          kuota: json['kuota'] as int? ?? 0,
          deskripsi: json['deskripsi'] as String? ?? '',
          bidangTersedia: List<String>.from(json['bidang_tersedia'] as List? ?? []),
          isManuallyOpen: json['is_manually_open'] as bool? ?? false,
        );
      }

      // 2. Fetch applicants
      // Note: This query may fail if the user role is not authenticated/admin because of RLS.
      // We wrap it in a try-catch, so if it fails (e.g. for non-logged-in applicants), it defaults to empty.
      try {
        final appData = await _db.from('or_pelamar').select().order('tanggal_daftar', ascending: false);
        _applicants = appData.map<ORApplicantModel>((json) {
          final id = json['id'] as String;
          final pid = json['periode_id'] as String? ?? '';
          final nama = json['nama'] as String? ?? '';
          final nim = json['nim'] as String? ?? '';
          final prodi = json['prodi'] as String? ?? '';
          final angkatan = json['angkatan'] as String? ?? '';
          final noHp = json['no_hp'] as String? ?? '';
          final bidangMinat = json['bidang_minat'] as String? ?? '';
          final motivasi = json['motivasi'] as String? ?? '';
          final pengalamanOrg = json['pengalaman_org'] as String? ?? '';
          final statusStr = json['status'] as String? ?? 'pending';
          final tanggalDaftar = DateTime.tryParse(json['tanggal_daftar'] ?? '') ?? DateTime.now();
          final catatan = json['catatan'] as String?;

          final status = ApplicantStatus.values.firstWhere(
            (e) => e.toString().split('.').last == statusStr,
            orElse: () => ApplicantStatus.pending,
          );

          return ORApplicantModel(
            id: id,
            periodeId: pid,
            nama: nama,
            nim: nim,
            prodi: prodi,
            angkatan: angkatan,
            noHp: noHp,
            bidangMinat: bidangMinat,
            motivasi: motivasi,
            pengalamanOrg: pengalamanOrg,
            status: status,
            tanggalDaftar: tanggalDaftar,
            catatan: catatan,
          );
        }).toList();
      } catch (_) {
        _applicants = [];
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading OR data: $e');
    }
  }

  @override
  ORPeriodeModel get orPeriode => _periode;
  
  @override
  List<ORApplicantModel> get applicants => List.unmodifiable(_applicants);

  @override
  void updatePeriode(ORPeriodeModel p) async {
    try {
      await _db.from('or_periode').upsert({
        'id': p.id.isNotEmpty ? p.id : null,
        'nama': p.nama,
        'tanggal_buka': p.tanggalBuka.toIso8601String(),
        'tanggal_tutup': p.tanggalTutup.toIso8601String(),
        'kuota': p.kuota,
        'deskripsi': p.deskripsi,
        'bidang_tersedia': p.bidangTersedia,
        'is_manually_open': p.isManuallyOpen,
      });
      _loadORData();
    } catch (e) {
      debugPrint('Error updating OR period: $e');
    }
  }

  @override
  void addApplicant(ORApplicantModel app) async {
    try {
      await _db.from('or_pelamar').insert({
        'periode_id': app.periodeId,
        'nama': app.nama,
        'nim': app.nim,
        'prodi': app.prodi,
        'angkatan': app.angkatan,
        'no_hp': app.noHp,
        'bidang_minat': app.bidangMinat,
        'motivasi': app.motivasi,
        'pengalaman_org': app.pengalamanOrg,
        'status': app.status.toString().split('.').last,
        'tanggal_daftar': app.tanggalDaftar.toIso8601String(),
        'catatan': app.catatan,
      });
      _loadORData();
    } catch (e) {
      debugPrint('Error adding applicant: $e');
    }
  }

  @override
  void reviewApplicant(String id, ApplicantStatus status, {String? catatan}) async {
    try {
      await _db.from('or_pelamar').update({
        'status': status.toString().split('.').last,
        'catatan': catatan,
      }).eq('id', id);
      _loadORData();
    } catch (e) {
      debugPrint('Error reviewing applicant: $e');
    }
  }
}
