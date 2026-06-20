class PeriodeModel {
  final String id;
  final String nama;           // contoh: 'Kepengurusan 2025/2026'
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final bool isActive;         // hanya 1 yang aktif dalam satu waktu

  const PeriodeModel({
    required this.id,
    required this.nama,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.isActive,
  });

  PeriodeModel copyWith({
    String? id,
    String? nama,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
    bool? isActive,
  }) {
    return PeriodeModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      isActive: isActive ?? this.isActive,
    );
  }

  factory PeriodeModel.fromJson(Map<String, dynamic> json) {
    return PeriodeModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      tanggalMulai: DateTime.parse(json['tanggalMulai'] as String),
      tanggalSelesai: DateTime.parse(json['tanggalSelesai'] as String),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'tanggalMulai': tanggalMulai.toIso8601String(),
      'tanggalSelesai': tanggalSelesai.toIso8601String(),
      'isActive': isActive,
    };
  }
}
