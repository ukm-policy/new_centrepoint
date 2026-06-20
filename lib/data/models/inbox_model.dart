enum TipeNotif { poin, kegiatan, absensi, uangKhas, sistem, pengumuman }

class NotifModel {
  final String id;
  final TipeNotif tipe;
  final String judul;
  final String isi;
  final DateTime waktu;
  final bool isRead;
  final String? route;         // deep link route dalam app

  const NotifModel({
    required this.id,
    required this.tipe,
    required this.judul,
    required this.isi,
    required this.waktu,
    required this.isRead,
    this.route,
  });

  NotifModel copyWith({
    String? id,
    TipeNotif? tipe,
    String? judul,
    String? isi,
    DateTime? waktu,
    bool? isRead,
    String? route,
  }) {
    return NotifModel(
      id: id ?? this.id,
      tipe: tipe ?? this.tipe,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      waktu: waktu ?? this.waktu,
      isRead: isRead ?? this.isRead,
      route: route ?? this.route,
    );
  }

  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      id: json['id'] as String,
      tipe: TipeNotif.values.firstWhere((e) => e.toString().split('.').last == json['tipe']),
      judul: json['judul'] as String,
      isi: json['isi'] as String,
      waktu: DateTime.parse(json['waktu'] as String),
      isRead: json['isRead'] as bool? ?? false,
      route: json['route'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipe': tipe.toString().split('.').last,
      'judul': judul,
      'isi': isi,
      'waktu': waktu.toIso8601String(),
      'isRead': isRead,
      'route': route,
    };
  }
}

class PengumumanModel {
  final String id;
  final String kategori;       // 'PENTING' | 'KEGIATAN' | 'KEUANGAN' | 'REKRUTMEN' | 'PRESTASI'
  final String judul;
  final String ringkasan;      // satu paragraf singkat
  final List<String> konten;   // list paragraf
  final DateTime tanggal;
  final bool isNew;
  final String? actionLabel;
  final String? actionRoute;

  const PengumumanModel({
    required this.id,
    required this.kategori,
    required this.judul,
    required this.ringkasan,
    required this.konten,
    required this.tanggal,
    required this.isNew,
    this.actionLabel,
    this.actionRoute,
  });

  PengumumanModel copyWith({
    String? id,
    String? kategori,
    String? judul,
    String? ringkasan,
    List<String>? konten,
    DateTime? tanggal,
    bool? isNew,
    String? actionLabel,
    String? actionRoute,
  }) {
    return PengumumanModel(
      id: id ?? this.id,
      kategori: kategori ?? this.kategori,
      judul: judul ?? this.judul,
      ringkasan: ringkasan ?? this.ringkasan,
      konten: konten ?? this.konten,
      tanggal: tanggal ?? this.tanggal,
      isNew: isNew ?? this.isNew,
      actionLabel: actionLabel ?? this.actionLabel,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }

  factory PengumumanModel.fromJson(Map<String, dynamic> json) {
    return PengumumanModel(
      id: json['id'] as String,
      kategori: json['kategori'] as String,
      judul: json['judul'] as String,
      ringkasan: json['ringkasan'] as String,
      konten: List<String>.from(json['konten'] as List<dynamic>? ?? const []),
      tanggal: DateTime.parse(json['tanggal'] as String),
      isNew: json['isNew'] as bool? ?? false,
      actionLabel: json['actionLabel'] as String?,
      actionRoute: json['actionRoute'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kategori': kategori,
      'judul': judul,
      'ringkasan': ringkasan,
      'konten': konten,
      'tanggal': tanggal.toIso8601String(),
      'isNew': isNew,
      'actionLabel': actionLabel,
      'actionRoute': actionRoute,
    };
  }
}
