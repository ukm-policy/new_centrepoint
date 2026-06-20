enum StatusAbsensi { hadir, izin, absen, belumAbsen }

class AbsensiModel {
  final String id;
  final String memberId;          // ref ke MemberModel.id
  final String memberNama;        // denormalized
  final String kegiatanId;        // ref ke KegiatanModel.id atau RapatModel.id
  final String kegiatanJudul;     // denormalized
  final String tipeKegiatan;      // 'kegiatan' | 'rapat'
  final StatusAbsensi status;
  final DateTime? waktuScan;      // null jika belum absen
  final String? keterangan;       // diisi jika izin

  const AbsensiModel({
    required this.id,
    required this.memberId,
    required this.memberNama,
    required this.kegiatanId,
    required this.kegiatanJudul,
    required this.tipeKegiatan,
    required this.status,
    this.waktuScan,
    this.keterangan,
  });

  AbsensiModel copyWith({
    String? id,
    String? memberId,
    String? memberNama,
    String? kegiatanId,
    String? kegiatanJudul,
    String? tipeKegiatan,
    StatusAbsensi? status,
    DateTime? waktuScan,
    String? keterangan,
  }) {
    return AbsensiModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberNama: memberNama ?? this.memberNama,
      kegiatanId: kegiatanId ?? this.kegiatanId,
      kegiatanJudul: kegiatanJudul ?? this.kegiatanJudul,
      tipeKegiatan: tipeKegiatan ?? this.tipeKegiatan,
      status: status ?? this.status,
      waktuScan: waktuScan ?? this.waktuScan,
      keterangan: keterangan ?? this.keterangan,
    );
  }

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    return AbsensiModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberNama: json['memberNama'] as String,
      kegiatanId: json['kegiatanId'] as String,
      kegiatanJudul: json['kegiatanJudul'] as String,
      tipeKegiatan: json['tipeKegiatan'] as String,
      status: StatusAbsensi.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      waktuScan: json['waktuScan'] != null ? DateTime.parse(json['waktuScan'] as String) : null,
      keterangan: json['keterangan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'memberNama': memberNama,
      'kegiatanId': kegiatanId,
      'kegiatanJudul': kegiatanJudul,
      'tipeKegiatan': tipeKegiatan,
      'status': status.toString().split('.').last,
      'waktuScan': waktuScan?.toIso8601String(),
      'keterangan': keterangan,
    };
  }
}

class QrSessionModel {
  final String id;
  final String kegiatanId;
  final String kegiatanJudul;
  final DateTime tanggal;
  final DateTime expiredAt;
  final bool isActive;

  const QrSessionModel({
    required this.id,
    required this.kegiatanId,
    required this.kegiatanJudul,
    required this.tanggal,
    required this.expiredAt,
    required this.isActive,
  });

  QrSessionModel copyWith({
    String? id,
    String? kegiatanId,
    String? kegiatanJudul,
    DateTime? tanggal,
    DateTime? expiredAt,
    bool? isActive,
  }) {
    return QrSessionModel(
      id: id ?? this.id,
      kegiatanId: kegiatanId ?? this.kegiatanId,
      kegiatanJudul: kegiatanJudul ?? this.kegiatanJudul,
      tanggal: tanggal ?? this.tanggal,
      expiredAt: expiredAt ?? this.expiredAt,
      isActive: isActive ?? this.isActive,
    );
  }

  factory QrSessionModel.fromJson(Map<String, dynamic> json) {
    return QrSessionModel(
      id: json['id'] as String,
      kegiatanId: json['kegiatanId'] as String,
      kegiatanJudul: json['kegiatanJudul'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      expiredAt: DateTime.parse(json['expiredAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kegiatanId': kegiatanId,
      'kegiatanJudul': kegiatanJudul,
      'tanggal': tanggal.toIso8601String(),
      'expiredAt': expiredAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}
