class MemberModel {
  final String id;
  final String nama;
  final String nim;
  final String email;
  final String noHp;
  final String prodi;
  final String angkatan;
  final String role;           // 'anggota' | 'staff' | 'ketua' | 'demisioner' | 'admin'
  final String? bidang;        // 'Pemrograman' | 'Jaringan' | 'Multimedia' | 'Pengembangan' | 'Kaderisasi' | 'Humas' | null
  final String? jabatan;
  final String tier;           // 'Gold' | 'Silver' | 'Bronze' | 'Member'
  final int totalPoin;
  final int kegiatanCount;
  final double kehadiranRate;  // 0.0 - 1.0
  final bool isActive;
  final String? avatarUrl;
  final String status;         // 'Aktif' | 'Pending' | 'Suspended'
  final int level;             // 1 | 2 | 3 | 4 | 5
  final bool isAdmin;

  const MemberModel({
    required this.id,
    required this.nama,
    required this.nim,
    required this.email,
    required this.noHp,
    required this.prodi,
    required this.angkatan,
    required this.role,
    this.bidang,
    this.jabatan,
    required this.tier,
    required this.totalPoin,
    required this.kegiatanCount,
    required this.kehadiranRate,
    required this.isActive,
    this.avatarUrl,
    this.status = 'Aktif',
    this.level = 2,
    this.isAdmin = false,
  });

  MemberModel copyWith({
    String? id,
    String? nama,
    String? nim,
    String? email,
    String? noHp,
    String? prodi,
    String? angkatan,
    String? role,
    String? bidang,
    String? jabatan,
    String? tier,
    int? totalPoin,
    int? kegiatanCount,
    double? kehadiranRate,
    bool? isActive,
    String? avatarUrl,
    String? status,
    int? level,
    bool? isAdmin,
  }) {
    return MemberModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      nim: nim ?? this.nim,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      prodi: prodi ?? this.prodi,
      angkatan: angkatan ?? this.angkatan,
      role: role ?? this.role,
      bidang: bidang ?? this.bidang,
      jabatan: jabatan ?? this.jabatan,
      tier: tier ?? this.tier,
      totalPoin: totalPoin ?? this.totalPoin,
      kegiatanCount: kegiatanCount ?? this.kegiatanCount,
      kehadiranRate: kehadiranRate ?? this.kehadiranRate,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      level: level ?? this.level,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      nim: json['nim'] as String,
      email: json['email'] as String,
      noHp: json['noHp'] as String,
      prodi: json['prodi'] as String,
      angkatan: json['angkatan'] as String,
      role: json['role'] as String,
      bidang: json['bidang'] as String?,
      jabatan: json['jabatan'] as String?,
      tier: json['tier'] as String,
      totalPoin: json['totalPoin'] as int? ?? 0,
      kegiatanCount: json['kegiatanCount'] as int? ?? 0,
      kehadiranRate: (json['kehadiranRate'] as num? ?? 0.0).toDouble(),
      isActive: json['isActive'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      status: json['status'] as String? ?? 'Aktif',
      level: json['level'] as int? ?? 2,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nim': nim,
      'email': email,
      'noHp': noHp,
      'prodi': prodi,
      'angkatan': angkatan,
      'role': role,
      'bidang': bidang,
      'jabatan': jabatan,
      'tier': tier,
      'totalPoin': totalPoin,
      'kegiatanCount': kegiatanCount,
      'kehadiranRate': kehadiranRate,
      'isActive': isActive,
      'avatarUrl': avatarUrl,
      'status': status,
      'level': level,
      'isAdmin': isAdmin,
    };
  }
}
