class PanitiaModel {
  final String memberId;       // ref ke MemberModel.id
  final String nama;           // denormalized
  final String nim;            // denormalized

  const PanitiaModel({
    required this.memberId,
    required this.nama,
    required this.nim,
  });

  factory PanitiaModel.fromJson(Map<String, dynamic> json) {
    return PanitiaModel(
      memberId: json['memberId'] as String,
      nama: json['nama'] as String,
      nim: json['nim'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberId': memberId,
      'nama': nama,
      'nim': nim,
    };
  }
}

class SieModel {
  final String namaSie;
  final PanitiaModel? ketua;
  final List<PanitiaModel> anggota;

  const SieModel({
    required this.namaSie,
    this.ketua,
    this.anggota = const [],
  });

  factory SieModel.fromJson(Map<String, dynamic> json) {
    return SieModel(
      namaSie: json['namaSie'] as String,
      ketua: json['ketua'] != null ? PanitiaModel.fromJson(json['ketua'] as Map<String, dynamic>) : null,
      anggota: (json['anggota'] as List<dynamic>?)?.map((e) => PanitiaModel.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'namaSie': namaSie,
      'ketua': ketua?.toJson(),
      'anggota': anggota.map((e) => e.toJson()).toList(),
    };
  }
}

class KegiatanModel {
  final String id;
  final String judul;
  final String deskripsi;
  final DateTime tanggal;
  final String waktu;          // contoh: '09.00 – 12.00 WIB'
  final String lokasi;
  final String status;         // 'Akan Datang' | 'Berlangsung' | 'Selesai' | 'Dibatalkan'
  final int kuota;
  final int pesertaTerdaftar;
  final PanitiaModel? ketuaPelaksana;
  final PanitiaModel? sekretarisPelaksana;
  final PanitiaModel? bendaharaPelaksana;
  final List<SieModel> sie;
  final String periodeId;      // ref ke PeriodeModel.id

  const KegiatanModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
    required this.waktu,
    required this.lokasi,
    required this.status,
    required this.kuota,
    required this.pesertaTerdaftar,
    this.ketuaPelaksana,
    this.sekretarisPelaksana,
    this.bendaharaPelaksana,
    this.sie = const [],
    required this.periodeId,
  });

  KegiatanModel copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    DateTime? tanggal,
    String? waktu,
    String? lokasi,
    String? status,
    int? kuota,
    int? pesertaTerdaftar,
    PanitiaModel? ketuaPelaksana,
    PanitiaModel? sekretarisPelaksana,
    PanitiaModel? bendaharaPelaksana,
    List<SieModel>? sie,
    String? periodeId,
  }) {
    return KegiatanModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      tanggal: tanggal ?? this.tanggal,
      waktu: waktu ?? this.waktu,
      lokasi: lokasi ?? this.lokasi,
      status: status ?? this.status,
      kuota: kuota ?? this.kuota,
      pesertaTerdaftar: pesertaTerdaftar ?? this.pesertaTerdaftar,
      ketuaPelaksana: ketuaPelaksana ?? this.ketuaPelaksana,
      sekretarisPelaksana: sekretarisPelaksana ?? this.sekretarisPelaksana,
      bendaharaPelaksana: bendaharaPelaksana ?? this.bendaharaPelaksana,
      sie: sie ?? this.sie,
      periodeId: periodeId ?? this.periodeId,
    );
  }

  factory KegiatanModel.fromJson(Map<String, dynamic> json) {
    return KegiatanModel(
      id: json['id'] as String,
      judul: json['judul'] as String,
      deskripsi: json['deskripsi'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      waktu: json['waktu'] as String,
      lokasi: json['lokasi'] as String,
      status: json['status'] as String,
      kuota: json['kuota'] as int? ?? 0,
      pesertaTerdaftar: json['pesertaTerdaftar'] as int? ?? 0,
      ketuaPelaksana: json['ketuaPelaksana'] != null ? PanitiaModel.fromJson(json['ketuaPelaksana'] as Map<String, dynamic>) : null,
      sekretarisPelaksana: json['sekretarisPelaksana'] != null ? PanitiaModel.fromJson(json['sekretarisPelaksana'] as Map<String, dynamic>) : null,
      bendaharaPelaksana: json['bendaharaPelaksana'] != null ? PanitiaModel.fromJson(json['bendaharaPelaksana'] as Map<String, dynamic>) : null,
      sie: (json['sie'] as List<dynamic>?)?.map((e) => SieModel.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
      periodeId: json['periodeId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'tanggal': tanggal.toIso8601String(),
      'waktu': waktu,
      'lokasi': lokasi,
      'status': status,
      'kuota': kuota,
      'pesertaTerdaftar': pesertaTerdaftar,
      'ketuaPelaksana': ketuaPelaksana?.toJson(),
      'sekretarisPelaksana': sekretarisPelaksana?.toJson(),
      'bendaharaPelaksana': bendaharaPelaksana?.toJson(),
      'sie': sie.map((e) => e.toJson()).toList(),
      'periodeId': periodeId,
    };
  }
}
