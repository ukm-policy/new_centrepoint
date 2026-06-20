enum StatusBayar { lunas, belumBayar, pending }

class UangKhasBulanModel {
  final String id;
  final String memberId;
  final String bulan;          // 'Januari 2026', dst
  final int tahun;
  final int nominal;           // dalam Rupiah
  final StatusBayar status;
  final DateTime? tanggalBayar;
  final String? buktiUrl;      // URL bukti transfer
  final bool isVerified;

  const UangKhasBulanModel({
    required this.id,
    required this.memberId,
    required this.bulan,
    required this.tahun,
    required this.nominal,
    required this.status,
    this.tanggalBayar,
    this.buktiUrl,
    required this.isVerified,
  });

  UangKhasBulanModel copyWith({
    String? id,
    String? memberId,
    String? bulan,
    int? tahun,
    int? nominal,
    StatusBayar? status,
    DateTime? tanggalBayar,
    String? buktiUrl,
    bool? isVerified,
  }) {
    return UangKhasBulanModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      bulan: bulan ?? this.bulan,
      tahun: tahun ?? this.tahun,
      nominal: nominal ?? this.nominal,
      status: status ?? this.status,
      tanggalBayar: tanggalBayar ?? this.tanggalBayar,
      buktiUrl: buktiUrl ?? this.buktiUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  factory UangKhasBulanModel.fromJson(Map<String, dynamic> json) {
    return UangKhasBulanModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      bulan: json['bulan'] as String,
      tahun: json['tahun'] as int? ?? 2026,
      nominal: json['nominal'] as int? ?? 10000,
      status: StatusBayar.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      tanggalBayar: json['tanggalBayar'] != null ? DateTime.parse(json['tanggalBayar'] as String) : null,
      buktiUrl: json['buktiUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'bulan': bulan,
      'tahun': tahun,
      'nominal': nominal,
      'status': status.toString().split('.').last,
      'tanggalBayar': tanggalBayar?.toIso8601String(),
      'buktiUrl': buktiUrl,
      'isVerified': isVerified,
    };
  }
}

class TransaksiKhasModel {
  final String id;
  final String label;
  final DateTime tanggal;
  final int jumlah;
  final bool isPemasukan;      // true = pemasukan, false = pengeluaran
  final bool isPending;
  final String? keterangan;

  const TransaksiKhasModel({
    required this.id,
    required this.label,
    required this.tanggal,
    required this.jumlah,
    required this.isPemasukan,
    required this.isPending,
    this.keterangan,
  });

  TransaksiKhasModel copyWith({
    String? id,
    String? label,
    DateTime? tanggal,
    int? jumlah,
    bool? isPemasukan,
    bool? isPending,
    String? keterangan,
  }) {
    return TransaksiKhasModel(
      id: id ?? this.id,
      label: label ?? this.label,
      tanggal: tanggal ?? this.tanggal,
      jumlah: jumlah ?? this.jumlah,
      isPemasukan: isPemasukan ?? this.isPemasukan,
      isPending: isPending ?? this.isPending,
      keterangan: keterangan ?? this.keterangan,
    );
  }

  factory TransaksiKhasModel.fromJson(Map<String, dynamic> json) {
    return TransaksiKhasModel(
      id: json['id'] as String,
      label: json['label'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      jumlah: json['jumlah'] as int? ?? 0,
      isPemasukan: json['isPemasukan'] as bool? ?? true,
      isPending: json['isPending'] as bool? ?? false,
      keterangan: json['keterangan'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'tanggal': tanggal.toIso8601String(),
      'jumlah': jumlah,
      'isPemasukan': isPemasukan,
      'isPending': isPending,
      'keterangan': keterangan,
    };
  }
}
