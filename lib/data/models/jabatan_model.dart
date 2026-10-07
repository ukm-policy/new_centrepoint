/// Satu baris tabel `jabatan` (beserta nama bidangnya, bila ada).
class JabatanModel {
  final int id;
  final String nama;
  final int levelAkses;
  final String kodeRole;
  final String? bidang;

  const JabatanModel({
    required this.id,
    required this.nama,
    required this.levelAkses,
    required this.kodeRole,
    this.bidang,
  });

  /// Label untuk dropdown: nama jabatan + bidang jika belum tersebut di nama.
  String get label =>
      bidang == null || nama.toLowerCase().contains(bidang!.toLowerCase())
      ? nama
      : '$nama — $bidang';

  factory JabatanModel.fromJson(Map<String, dynamic> json) {
    return JabatanModel(
      id: (json['id'] as num).toInt(),
      nama: json['nama'] as String? ?? '-',
      levelAkses: (json['level_akses'] as num?)?.toInt() ?? 1,
      kodeRole: json['kode_role'] as String? ?? '',
      bidang: (json['bidang'] as Map<String, dynamic>?)?['nama'] as String?,
    );
  }
}
