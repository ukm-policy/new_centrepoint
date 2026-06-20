class BeritaModel {
  final String id;
  final String judul;
  final String kategori;       // 'Berita' | 'Pengumuman'
  final String konten;
  final String? thumbnailUrl;
  final String penulisId;      // ref ke UserModel.id
  final String penulisNama;    // denormalized untuk display
  final DateTime tanggalPublish;
  final bool isDraft;

  const BeritaModel({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.konten,
    this.thumbnailUrl,
    required this.penulisId,
    required this.penulisNama,
    required this.tanggalPublish,
    required this.isDraft,
  });

  BeritaModel copyWith({
    String? id,
    String? judul,
    String? kategori,
    String? konten,
    String? thumbnailUrl,
    String? penulisId,
    String? penulisNama,
    DateTime? tanggalPublish,
    bool? isDraft,
  }) {
    return BeritaModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      kategori: kategori ?? this.kategori,
      konten: konten ?? this.konten,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      penulisId: penulisId ?? this.penulisId,
      penulisNama: penulisNama ?? this.penulisNama,
      tanggalPublish: tanggalPublish ?? this.tanggalPublish,
      isDraft: isDraft ?? this.isDraft,
    );
  }

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'] as String,
      judul: json['judul'] as String,
      kategori: json['kategori'] as String,
      konten: json['konten'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      penulisId: json['penulisId'] as String,
      penulisNama: json['penulisNama'] as String,
      tanggalPublish: DateTime.parse(json['tanggalPublish'] as String),
      isDraft: json['isDraft'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'kategori': kategori,
      'konten': konten,
      'thumbnailUrl': thumbnailUrl,
      'penulisId': penulisId,
      'penulisNama': penulisNama,
      'tanggalPublish': tanggalPublish.toIso8601String(),
      'isDraft': isDraft,
    };
  }
}
