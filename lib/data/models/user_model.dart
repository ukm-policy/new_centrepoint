class UserModel {
  final String id;
  final String nama;
  final String email;
  final String nim;
  final String noHp;
  final String prodi;
  final String angkatan;       // contoh: '2023'
  final String role;           // 'anggota' | 'staff' | 'ketua' | 'demisioner' | 'admin'
  final String? bidang;        // 'Pemrograman' | 'Jaringan' | 'Multimedia' | 'Pengembangan' | 'Kaderisasi' | 'Humas' | null
  final String? jabatan;       // null jika tidak ada jabatan khusus
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.nim,
    required this.noHp,
    required this.prodi,
    required this.angkatan,
    required this.role,
    this.bidang,
    this.jabatan,
    this.avatarUrl,
    required this.isVerified,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? nim,
    String? noHp,
    String? prodi,
    String? angkatan,
    String? role,
    String? bidang,
    String? jabatan,
    String? avatarUrl,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      nim: nim ?? this.nim,
      noHp: noHp ?? this.noHp,
      prodi: prodi ?? this.prodi,
      angkatan: angkatan ?? this.angkatan,
      role: role ?? this.role,
      bidang: bidang ?? this.bidang,
      jabatan: jabatan ?? this.jabatan,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      email: json['email'] as String,
      nim: json['nim'] as String,
      noHp: json['noHp'] as String,
      prodi: json['prodi'] as String,
      angkatan: json['angkatan'] as String,
      role: json['role'] as String,
      bidang: json['bidang'] as String?,
      jabatan: json['jabatan'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'nim': nim,
      'noHp': noHp,
      'prodi': prodi,
      'angkatan': angkatan,
      'role': role,
      'bidang': bidang,
      'jabatan': jabatan,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
