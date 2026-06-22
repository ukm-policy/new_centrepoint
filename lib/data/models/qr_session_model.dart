class QrSessionModel {
  final String id;
  final String kegiatanId;
  final String kegiatanJudul;
  final DateTime tanggal;
  final DateTime expiredAt;
  final String? createdBy;
  final String tipeKegiatan;
  final bool isActive;
  final DateTime createdAt;

  const QrSessionModel({
    required this.id,
    required this.kegiatanId,
    required this.kegiatanJudul,
    required this.tanggal,
    required this.expiredAt,
    this.createdBy,
    this.tipeKegiatan = 'kegiatan',
    this.isActive = true,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiredAt);

  Duration get remaining {
    final diff = expiredAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  factory QrSessionModel.fromJson(Map<String, dynamic> json) {
    return QrSessionModel(
      id: json['id'] as String,
      kegiatanId: json['kegiatan_id'] as String? ?? '',
      kegiatanJudul: json['kegiatan_judul'] as String? ?? '',
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
      expiredAt: DateTime.tryParse(json['expired_at'] ?? '') ?? DateTime.now(),
      createdBy: json['created_by'] as String?,
      tipeKegiatan: json['tipe_kegiatan'] as String? ?? 'kegiatan',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
