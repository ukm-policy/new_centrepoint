enum TipePoin { hadir, absen, panitia, bonus, penalti }

class PoinEntryModel {
  final String id;
  final String memberId;       // ref ke MemberModel.id
  final String memberNama;     // denormalized
  final String label;          // deskripsi aktivitas
  final TipePoin tipe;
  final int poin;              // bisa negatif untuk penalti/absen
  final DateTime tanggal;
  final String? kegiatanId;   // opsional, jika terkait kegiatan

  const PoinEntryModel({
    required this.id,
    required this.memberId,
    required this.memberNama,
    required this.label,
    required this.tipe,
    required this.poin,
    required this.tanggal,
    this.kegiatanId,
  });

  PoinEntryModel copyWith({
    String? id,
    String? memberId,
    String? memberNama,
    String? label,
    TipePoin? tipe,
    int? poin,
    DateTime? tanggal,
    String? kegiatanId,
  }) {
    return PoinEntryModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberNama: memberNama ?? this.memberNama,
      label: label ?? this.label,
      tipe: tipe ?? this.tipe,
      poin: poin ?? this.poin,
      tanggal: tanggal ?? this.tanggal,
      kegiatanId: kegiatanId ?? this.kegiatanId,
    );
  }

  factory PoinEntryModel.fromJson(Map<String, dynamic> json) {
    return PoinEntryModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberNama: json['memberNama'] as String,
      label: json['label'] as String,
      tipe: TipePoin.values.firstWhere((e) => e.toString().split('.').last == json['tipe']),
      poin: json['poin'] as int? ?? 0,
      tanggal: DateTime.parse(json['tanggal'] as String),
      kegiatanId: json['kegiatanId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'memberNama': memberNama,
      'label': label,
      'tipe': tipe.toString().split('.').last,
      'poin': poin,
      'tanggal': tanggal.toIso8601String(),
      'kegiatanId': kegiatanId,
    };
  }
}

class LeaderboardEntryModel {
  final int rank;
  final String memberId;
  final String memberNama;
  final String? divisi;
  final int totalPoin;
  final String tier;           // 'Gold' | 'Silver' | 'Bronze' | 'Member'

  const LeaderboardEntryModel({
    required this.rank,
    required this.memberId,
    required this.memberNama,
    this.divisi,
    required this.totalPoin,
    required this.tier,
  });

  LeaderboardEntryModel copyWith({
    int? rank,
    String? memberId,
    String? memberNama,
    String? divisi,
    int? totalPoin,
    String? tier,
  }) {
    return LeaderboardEntryModel(
      rank: rank ?? this.rank,
      memberId: memberId ?? this.memberId,
      memberNama: memberNama ?? this.memberNama,
      divisi: divisi ?? this.divisi,
      totalPoin: totalPoin ?? this.totalPoin,
      tier: tier ?? this.tier,
    );
  }

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] as int? ?? 0,
      memberId: json['memberId'] as String,
      memberNama: json['memberNama'] as String,
      divisi: json['divisi'] as String?,
      totalPoin: json['totalPoin'] as int? ?? 0,
      tier: json['tier'] as String? ?? 'Member',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'memberId': memberId,
      'memberNama': memberNama,
      'divisi': divisi,
      'totalPoin': totalPoin,
      'tier': tier,
    };
  }
}
