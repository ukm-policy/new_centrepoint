enum ORStatus { belumBuka, buka, ditutup }
enum ApplicantStatus { pending, diterima, ditolak }

class ORPeriodeModel {
  final String id;
  final String nama;           // contoh: 'OR 2026/2027'
  final DateTime tanggalBuka;
  final DateTime tanggalTutup;
  final int kuota;
  final String deskripsi;
  final List<String> bidangTersedia;  // subset dari: ['Pemrograman', 'Jaringan', 'Multimedia', 'Pengembangan', 'Kaderisasi', 'Humas']
  final bool isManuallyOpen;

  const ORPeriodeModel({
    required this.id,
    required this.nama,
    required this.tanggalBuka,
    required this.tanggalTutup,
    required this.kuota,
    required this.deskripsi,
    required this.bidangTersedia,
    required this.isManuallyOpen,
  });

  ORStatus get status {
    if (!isManuallyOpen) return ORStatus.ditutup;
    final now = DateTime.now();
    if (now.isBefore(tanggalBuka)) return ORStatus.belumBuka;
    if (now.isAfter(tanggalTutup)) return ORStatus.ditutup;
    return ORStatus.buka;
  }

  int get sisaHari {
    final now = DateTime.now();
    if (now.isAfter(tanggalTutup)) return 0;
    return tanggalTutup.difference(now).inDays;
  }

  ORPeriodeModel copyWith({
    String? id,
    String? nama,
    DateTime? tanggalBuka,
    DateTime? tanggalTutup,
    int? kuota,
    String? deskripsi,
    List<String>? bidangTersedia,
    bool? isManuallyOpen,
  }) {
    return ORPeriodeModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tanggalBuka: tanggalBuka ?? this.tanggalBuka,
      tanggalTutup: tanggalTutup ?? this.tanggalTutup,
      kuota: kuota ?? this.kuota,
      deskripsi: deskripsi ?? this.deskripsi,
      bidangTersedia: bidangTersedia ?? this.bidangTersedia,
      isManuallyOpen: isManuallyOpen ?? this.isManuallyOpen,
    );
  }

  factory ORPeriodeModel.fromJson(Map<String, dynamic> json) {
    return ORPeriodeModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      tanggalBuka: DateTime.parse(json['tanggalBuka'] as String),
      tanggalTutup: DateTime.parse(json['tanggalTutup'] as String),
      kuota: json['kuota'] as int? ?? 0,
      deskripsi: json['deskripsi'] as String,
      bidangTersedia: List<String>.from(json['bidangTersedia'] as List<dynamic>? ?? const []),
      isManuallyOpen: json['isManuallyOpen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'tanggalBuka': tanggalBuka.toIso8601String(),
      'tanggalTutup': tanggalTutup.toIso8601String(),
      'kuota': kuota,
      'deskripsi': deskripsi,
      'bidangTersedia': bidangTersedia,
      'isManuallyOpen': isManuallyOpen,
    };
  }
}

class ORApplicantModel {
  final String id;
  final String periodeId;      // ref ke ORPeriodeModel.id
  final String nama;
  final String nim;
  final String prodi;
  final String angkatan;
  final String noHp;
  final String bidangMinat;
  final String motivasi;
  final String pengalamanOrg;
  final ApplicantStatus status;
  final DateTime tanggalDaftar;
  final String? catatan;       // catatan reviewer

  const ORApplicantModel({
    required this.id,
    required this.periodeId,
    required this.nama,
    required this.nim,
    required this.prodi,
    required this.angkatan,
    required this.noHp,
    required this.bidangMinat,
    required this.motivasi,
    required this.pengalamanOrg,
    required this.status,
    required this.tanggalDaftar,
    this.catatan,
  });

  ORApplicantModel copyWith({
    String? id,
    String? periodeId,
    String? nama,
    String? nim,
    String? prodi,
    String? angkatan,
    String? noHp,
    String? bidangMinat,
    String? motivasi,
    String? pengalamanOrg,
    ApplicantStatus? status,
    DateTime? tanggalDaftar,
    String? catatan,
  }) {
    return ORApplicantModel(
      id: id ?? this.id,
      periodeId: periodeId ?? this.periodeId,
      nama: nama ?? this.nama,
      nim: nim ?? this.nim,
      prodi: prodi ?? this.prodi,
      angkatan: angkatan ?? this.angkatan,
      noHp: noHp ?? this.noHp,
      bidangMinat: bidangMinat ?? this.bidangMinat,
      motivasi: motivasi ?? this.motivasi,
      pengalamanOrg: pengalamanOrg ?? this.pengalamanOrg,
      status: status ?? this.status,
      tanggalDaftar: tanggalDaftar ?? this.tanggalDaftar,
      catatan: catatan ?? this.catatan,
    );
  }

  factory ORApplicantModel.fromJson(Map<String, dynamic> json) {
    return ORApplicantModel(
      id: json['id'] as String,
      periodeId: json['periodeId'] as String,
      nama: json['nama'] as String,
      nim: json['nim'] as String,
      prodi: json['prodi'] as String,
      angkatan: json['angkatan'] as String,
      noHp: json['noHp'] as String,
      bidangMinat: json['bidangMinat'] as String,
      motivasi: json['motivasi'] as String,
      pengalamanOrg: json['pengalamanOrg'] as String,
      status: ApplicantStatus.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      tanggalDaftar: DateTime.parse(json['tanggalDaftar'] as String),
      catatan: json['catatan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodeId': periodeId,
      'nama': nama,
      'nim': nim,
      'prodi': prodi,
      'angkatan': angkatan,
      'noHp': noHp,
      'bidangMinat': bidangMinat,
      'motivasi': motivasi,
      'pengalamanOrg': pengalamanOrg,
      'status': status.toString().split('.').last,
      'tanggalDaftar': tanggalDaftar.toIso8601String(),
      'catatan': catatan,
    };
  }
}
